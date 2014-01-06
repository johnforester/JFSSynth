//
//  JFSKeyboardView.m
//  JFSynth
//
//  Created by jforester on 11/19/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSScrollingKeyboardView.h"

#define KEYBOARD_HEIGHT 180
#define MINI_KEYBOARD_HEIGHT 40

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
        _scrollView.scrollEnabled = NO;
        [self addSubview:_scrollView];
    } else {
        _scrollView.frame = scrollViewFrame;
    }
    
    int whiteKeyCount = 77;

    CGFloat whiteKeyWidth = frame.size.width / 12;
    CGFloat whiteKeyHeight = KEYBOARD_HEIGHT;
    
    CGFloat miniWhiteKeyWidth = frame.size.width / 77;
    CGFloat miniWhiteKeyHeight = MINI_KEYBOARD_HEIGHT;
    
    CGFloat blackKeyWidth = whiteKeyWidth/2;
    CGFloat blackKeyHeight = whiteKeyHeight/2;
    
    CGFloat miniBlackKeyWidth = miniWhiteKeyWidth/2;
    CGFloat miniBlackKeyHeight = miniWhiteKeyHeight/2;
    
    CGRect keyBoardFrame = CGRectMake(0, frame.size.height - KEYBOARD_HEIGHT, whiteKeyWidth * whiteKeyCount, KEYBOARD_HEIGHT);
    
    if (_keyboardView == nil) {
        _keyboardView = [[JFSKeyBoardView alloc] initWithFrame:keyBoardFrame];
        [_scrollView addSubview:_keyboardView];
    } else {
        _keyboardView.frame = keyBoardFrame;
    }
    
    if (_miniKeyboardView == nil) {
        _miniKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, MINI_KEYBOARD_HEIGHT)];
        _miniKeyboardView.userInteractionEnabled = NO;
        [self addSubview:_miniKeyboardView];
    }
    
    int currentWhiteKey = 0;
    int currentKey = 0;
    
    NSMutableArray *tempKeyLayers = nil;
    
    [_miniKeyboardView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    while (currentKey < 127) {
        for (int j = 0; j < 12; j++) {
            
            CGRect frame;
            CGRect miniFrame;
            BOOL blackKey = NO;
            
            //calculate new frame
            
            if (j == 1 || j == 3 || j == 6 || j == 8 || j == 10) {
                frame = CGRectMake((currentWhiteKey - 1) * whiteKeyWidth + (blackKeyWidth * 1.5), 0, blackKeyWidth, blackKeyHeight);
                miniFrame = CGRectMake((currentWhiteKey - 1) * miniWhiteKeyWidth + (miniBlackKeyWidth * 1.5), 0, miniBlackKeyWidth, miniBlackKeyHeight);
                
                blackKey = YES;
            } else {
                frame = CGRectMake(currentWhiteKey * whiteKeyWidth, 0, whiteKeyWidth, whiteKeyHeight);
                miniFrame = CGRectMake(currentWhiteKey * miniWhiteKeyWidth, 0, miniWhiteKeyWidth, miniWhiteKeyHeight);
                currentWhiteKey++;
            }
            
            //big playable keys
            
            JFSKeyView *keyView = _keyViews[currentKey];
            
            if (keyView == nil) {
                if (tempKeyLayers == nil) {
                    tempKeyLayers = [[NSMutableArray alloc] init];
                }
                
                keyView = [[JFSKeyView alloc] initWithFrame:frame blackKey:blackKey];
                [tempKeyLayers addObject:keyView];
                
                int note = currentKey;
                
                keyView.keyPressBlock = ^{
                    [self.delegate keyPressedWithMidiNote:note];
                };
                
                __weak UIView *weakKeyView = keyView;
                
                keyView.keyReleaseBlock = ^{
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
            
            //mini key
            if (blackKey) {
                UIView *miniBlackKey = [[UIView alloc] initWithFrame:miniFrame];
                miniBlackKey.backgroundColor = [UIColor blackColor];
                [_miniKeyboardView addSubview:miniBlackKey];
            } else {
                UIView *miniWhiteKey = [[UIView alloc] initWithFrame:miniFrame];
                miniWhiteKey.backgroundColor = [UIColor whiteColor];
                miniWhiteKey.layer.borderWidth = 0.5;
                miniWhiteKey.layer.borderColor = [UIColor blackColor].CGColor;
                [_miniKeyboardView addSubview:miniWhiteKey];
                [_miniKeyboardView sendSubviewToBack:miniWhiteKey];
            }
            
            currentKey++;
        }
    }
    
    if (tempKeyLayers) {
        _keyViews = [NSArray arrayWithArray:tempKeyLayers];
    }
    
    _scrollView.contentSize = CGSizeMake(_keyboardView.frame.size.width, 0);
    
    if (_indicator == nil) {
        _indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MINI_KEYBOARD_HEIGHT, MINI_KEYBOARD_HEIGHT)];
        _indicator.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
        
        [self insertSubview:_indicator aboveSubview:_miniKeyboardView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanIndicator:)];
        [_indicator addGestureRecognizer:pan];
    }
    
    _indicator.frame = CGRectMake((_scrollView.contentOffset.x/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  0,
                                  (_scrollView.frame.size.width/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                  40);
    
    if (!_initialLayoutCompleted) {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentSize.width/2, 0);
        _initialLayoutCompleted = YES;
        
        _indicator.frame = CGRectMake((_scrollView.contentOffset.x/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                      0,
                                      (_scrollView.frame.size.width/_scrollView.contentSize.width) * _scrollView.frame.size.width,
                                      40);
        
    }
}

#pragma mark - Pan

- (void)didPanIndicator:(UIPanGestureRecognizer *)panGestureRecognizer
{
    static BOOL moving;
    static CGPoint startingPoint;
    static CGPoint startingContentOffset;
    
    CGPoint translatedPoint = [panGestureRecognizer translationInView:self];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        moving = YES;
        startingPoint = self.indicator.frame.origin;
        startingContentOffset = self.scrollView.contentOffset;
    }
    
    if (moving) {
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
            panGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
            panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
            moving = NO;
        } else {
            CGFloat newCenterX = startingPoint.x + translatedPoint.x;
            
            if (newCenterX >= 0 &&
                newCenterX <= self.scrollView.frame.size.width - self.indicator.frame.size.width) {
                
                CGFloat newContentOffsetX = ((translatedPoint.x / self.scrollView.frame.size.width) * self.scrollView.contentSize.width) + startingContentOffset.x;
                
                CGPoint velocity = [panGestureRecognizer velocityInView:self];
                NSTimeInterval duration = fabs(translatedPoint.x) / velocity.x;
                
                [UIView animateWithDuration:duration animations:^{
                    self.indicator.frame = CGRectMake(newCenterX, 0, self.indicator.frame.size.width, self.indicator.frame.size.height);
                    self.scrollView.contentOffset = CGPointMake(newContentOffsetX, self.scrollView.contentOffset.y);
                }];
            }
        }
    }
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
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
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