//
//  JFSKeyboardView.m
//  JFSynth
//
//  Created by jforester on 11/19/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSScrollingKeyboardView.h"

#define KEYBOARD_HEIGHT 180

typedef void(^KeyPressBlock)();
typedef void(^KeyReleaseBlock)();

@interface JFSKeyView : UIView

@property (nonatomic, strong) KeyPressBlock keyPressBlock;
@property (nonatomic, strong) KeyReleaseBlock keyReleaseBlock;

- (instancetype)initWithFrame:(CGRect)frame blackKey:(BOOL)blackKey;
- (void)play;
- (void)stop;

@end

@interface JFSKeyBoardView : UIView

@property (nonatomic, strong) JFSKeyView *currentKey;

@end

@interface JFSScrollingKeyboardView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JFSKeyBoardView *keyboardView;
@property (nonatomic, strong) NSArray *keyViews;
@property (nonatomic, assign) BOOL initialLayoutCompleted;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) UILabel *octaveLabel;
@property (nonatomic, strong) UIView *miniKeyboardView;

@end

@implementation JFSScrollingKeyboardView

- (void)layoutSubviews
{
    CGRect frame = self.frame;
    
    CGRect scrollViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if (self.scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        [_scrollView flashScrollIndicators];
    } else {
        _scrollView.frame = scrollViewFrame;
    }
    
    CGFloat whiteKeyWidth = frame.size.width / 12;
    CGFloat whiteKeyHeight = KEYBOARD_HEIGHT;
    
    CGFloat blackKeyWidth = whiteKeyWidth/2;
    CGFloat blackKeyHeight = whiteKeyHeight/2;
    
    int whiteKeyCount = 77;
    
    CGRect keyBoardFrame = CGRectMake(0, frame.size.height - KEYBOARD_HEIGHT, whiteKeyWidth * whiteKeyCount, KEYBOARD_HEIGHT);
    
    if (_keyboardView == nil) {
        _keyboardView = [[JFSKeyBoardView alloc] initWithFrame:keyBoardFrame];
        [_scrollView addSubview:_keyboardView];
    } else {
        _keyboardView.frame = keyBoardFrame;
    }
    
    if (_indicator == nil) {
        _indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _indicator.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
        _indicator.userInteractionEnabled = NO;

        [_indicator addSubview:_octaveLabel];
        
        [self addSubview:_indicator];
    }
    
    int currentWhiteKey = 0;
    int currentKey = 0;
    
    NSMutableArray *tempKeyLayers = nil;
    
    while (currentKey < 127) {
        for (int j = 0; j < 12; j++) {
            
            CGRect frame;
            BOOL blackKey = NO;
            
            if (j == 1 || j == 3 || j == 6 || j == 8 || j == 10) {
                frame = CGRectMake((currentWhiteKey - 1) * whiteKeyWidth + (blackKeyWidth * 1.5), 0, blackKeyWidth, blackKeyHeight);
                blackKey = YES;
            } else {
                frame = CGRectMake(currentWhiteKey * whiteKeyWidth, 0, whiteKeyWidth, whiteKeyHeight);
                currentWhiteKey++;
            }
            
            JFSKeyView *keyView = self.keyViews[currentKey];
            
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
                    self.scrollView.scrollEnabled = NO;
                    [self.delegate keyPressedWithMidiNote:note];
                };
                
                __weak UIView *weakKeyView = keyView;
                
                keyView.keyReleaseBlock = ^{
                    self.scrollView.scrollEnabled = YES;
                    if (self.keyboardView.currentKey == weakKeyView) {
                        [self.delegate keyReleasedWithMidiNote:note];
                    }
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
        self.keyViews = [NSArray arrayWithArray:tempKeyLayers];
    }
    
    _scrollView.contentSize = CGSizeMake(_keyboardView.frame.size.width, 0);
    
    _indicator.frame = CGRectMake((_scrollView.contentOffset.x/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  0,
                                  (_scrollView.frame.size.width/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  40);
    
    if (_miniKeyboardView == nil) {
        _miniKeyboardView = [_keyboardView snapshotViewAfterScreenUpdates:YES];
        _miniKeyboardView.userInteractionEnabled = NO;
        [self insertSubview:_miniKeyboardView belowSubview:_indicator];
    }
    
    _miniKeyboardView.transform = CGAffineTransformMakeScale(_scrollView.frame.size.width/_keyboardView.frame.size.width, 40 / _keyboardView.frame.size.height);
    _miniKeyboardView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, 40);
    
    if (!_initialLayoutCompleted) {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentSize.width/2, 0);
        _initialLayoutCompleted = YES;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _indicator.frame = CGRectMake((_scrollView.contentOffset.x/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  0,
                                  (_scrollView.frame.size.width/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  40);
}

@end

@implementation JFSKeyBoardView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    JFSKeyView *nextKey = (JFSKeyView *)[self hitTest:[touch locationInView:self] withEvent:event];
    
    if (nextKey) {
        self.currentKey = nextKey;
        [self.currentKey play];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    JFSKeyView *nextKey = (JFSKeyView *)[self hitTest:[touch locationInView:self] withEvent:event];
    
    if (nextKey != self.currentKey) {
        
        [self.currentKey stop];
        
        if (nextKey) {
            [nextKey play];
        }
        
        self.currentKey = nextKey;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.currentKey stop];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.currentKey stop];
}

@end

@interface JFSKeyView()

@property (nonatomic, strong) UIColor *originalBackgroundColor;
@property (nonatomic, assign) BOOL isPlaying;

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

#pragma mark - key start and stop

- (void)play
{
    self.isPlaying = YES;
    self.backgroundColor = [UIColor grayColor];
    self.keyPressBlock();
}

- (void)stop
{
    //delayed so that some sound will play on a very quick release
    //TODO figure out a way to do this without delay
    
    double delayInSeconds = 0.007;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.isPlaying) {
            self.isPlaying = NO;
            self.backgroundColor = self.originalBackgroundColor;
            self.keyReleaseBlock();
        }
    });
}

@end