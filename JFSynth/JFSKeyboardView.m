//
//  JFSKeyboardView.m
//  JFSynth
//
//  Created by jforester on 11/19/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSKeyboardView.h"

typedef void(^KeyPressBlock)();
typedef void(^KeyReleaseBlock)();

@interface JFSKeyView : UIView

@property (nonatomic, strong) KeyPressBlock keyPressBlock;
@property (nonatomic, strong) KeyReleaseBlock keyReleaseBlock;

- (instancetype)initWithFrame:(CGRect)frame blackKey:(BOOL)blackKey;

@end

@interface JFSKeyboardView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *keyboardView;
@property (nonatomic, strong) NSArray *keyLayers;

@end

@implementation JFSKeyboardView

- (void)layoutSubviews
{
    CGRect frame = self.frame;
    
    CGRect scrollViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if (self.scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        [self addSubview:_scrollView];
    } else {
        _scrollView.frame = scrollViewFrame;
    }
    
    CGFloat whiteKeyWidth = frame.size.width / 12;
    CGFloat whiteKeyHeight = frame.size.height;
    
    CGFloat blackKeyWidth = whiteKeyWidth/2;
    CGFloat blackKeyHeight = whiteKeyHeight/2;
    
    int whiteKeyCount = 77;
    
    CGRect keyBoardFrame = CGRectMake(0, 0, whiteKeyWidth * whiteKeyCount, frame.size.height);
    
    if (_keyboardView == nil) {
        _keyboardView = [[UIView alloc] initWithFrame:keyBoardFrame];
        [_scrollView addSubview:_keyboardView];
    } else {
        _keyboardView.frame = keyBoardFrame;
    }
    
    int currentWhiteKey = 0;
    int currentKey = 0;
    
    NSMutableArray *tempKeyLayers = nil;
    
    while (currentKey < 127) {
        for (int j = 0; j < 12; j++) {
            
            CGRect frame;
            BOOL blackKey = NO;
            
            if (j == 1 || j == 4 || j == 6 || j == 8 || j == 11) {
                frame = CGRectMake((currentWhiteKey - 1) * whiteKeyWidth + (blackKeyWidth * 1.5), 0, blackKeyWidth, blackKeyHeight);
                blackKey = YES;
            } else {
                frame = CGRectMake(currentWhiteKey * whiteKeyWidth, 0, whiteKeyWidth, whiteKeyHeight);
                currentWhiteKey++;
            }
            
            JFSKeyView *keyView = self.keyLayers[currentKey];
            
            if (keyView == nil) {
                if (tempKeyLayers == nil) {
                    tempKeyLayers = [[NSMutableArray alloc] init];
                }
                
                keyView = [[JFSKeyView alloc] initWithFrame:frame blackKey:blackKey];
                [tempKeyLayers addObject:keyView];
                keyView.layer.borderColor = [UIColor blackColor].CGColor;
                keyView.layer.borderWidth = 1.0;
                
                int note = currentKey;
                
                keyView.keyPressBlock = ^{
                    [self.delegate keyPressedWithMidiNote:note];
                };
                
                keyView.keyReleaseBlock = ^{
                    [self.delegate keyReleasedWithMidiNote:note];
                };
                
                [_keyboardView addSubview:keyView];
                
                if (blackKey) {
                    [_keyboardView bringSubviewToFront:keyView];
                } else {
                    [_keyboardView sendSubviewToBack:keyView];
                }
            } else {
                keyView.frame = frame;
            }

            currentKey++;
        }
    }
    
    if (tempKeyLayers) {
        self.keyLayers = [NSArray arrayWithArray:tempKeyLayers];
    }
    
    _scrollView.contentSize = CGSizeMake(_keyboardView.frame.size.width, 0);
}

@end

@interface JFSKeyView()

@property (nonatomic, strong) UIColor *originalBackgroundColor;

@end

@implementation JFSKeyView

- (instancetype)initWithFrame:(CGRect)frame blackKey:(BOOL)blackKey
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _originalBackgroundColor = blackKey ? [UIColor blackColor] : [UIColor whiteColor];
        self.backgroundColor = _originalBackgroundColor;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor grayColor];
    
    self.keyPressBlock();
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = self.originalBackgroundColor;
    
    self.keyReleaseBlock();
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = self.originalBackgroundColor;
    
    self.keyReleaseBlock();}

@end