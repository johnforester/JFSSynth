//
//  JFSEnvelopeView.m
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeView.h"

#define ATTACK_X_RIGHT_BOUND CGRectGetWidth(self.envelopeContainer.frame) / 3
#define RELEASE_X_LEFT_BOUND (CGRectGetWidth(self.envelopeContainer.frame) / 3) * 2
#define TOUCH_POINTS_RADIUS 10

@interface JFSEnvelopeView ()
{
    CGPoint _points[JFSEnvelopeViewPointCount];
    CGAffineTransform _touchPointsTransform;
    BOOL _isMoving;
}

@property (nonatomic, strong) CAShapeLayer *envelopeLayer;
@property (nonatomic, strong) CALayer *borderLayer;
@property (nonatomic, strong) NSDictionary *touchPointLayers;
@property (nonatomic, strong) UIView *envelopeContainer;
@property (nonatomic, strong) CALayer *currentStageLayer;
@property (nonatomic, assign) JFSEnvelopeViewStagePoint currentPoint;

@end

@implementation JFSEnvelopeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setUpView];
    }
    
    return self;
}

#pragma mark - accessors

- (void)setDataSource:(id<JFSEnvelopeViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self refreshView];
}

#pragma mark - view setup and refresh

- (void)setUpView
{
    _touchPointsTransform = CGAffineTransformMakeRotation(2 * M_PI);
    _envelopeContainer = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
    _envelopeContainer.backgroundColor = [UIColor blackColor];
    
    _borderLayer = [CALayer layer];
    _borderLayer.frame = CGRectMake(0, 0, _envelopeContainer.frame.size.width, _envelopeContainer.frame.size.height);
    _borderLayer.borderColor = [UIColor redColor].CGColor;
    _borderLayer.borderWidth = 1.0f;
    [_envelopeContainer.layer addSublayer:_borderLayer];
    
    _envelopeContainer.userInteractionEnabled = NO;
    
    [self addSubview:_envelopeContainer];
}

- (void)refreshView
{
    CGRect envelopeFrame = self.envelopeContainer.frame;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(envelopeFrame))];
    
    CGFloat maxWidth = [self maxSegmentWidth];
    CGFloat maxTime = [_dataSource maxEnvelopeTimeForEnvelopeView:self];
    
    CGFloat attackWidth = ([_dataSource attackTimeForEnvelopeView:self] / maxTime) * maxWidth;
    CGFloat decayWidth = ([_dataSource decayTimeForEnvelopeView:self] / maxTime) * maxWidth;
    CGFloat releaseWidth = ([_dataSource releaseTimeForEnvelopeView:self] / maxTime) * maxWidth;
    
    CGFloat sustainHeight = [_dataSource sustainPercentageOfPeakForEnvelopeView:self] * CGRectGetHeight(envelopeFrame);
    
    _points[JFSEnvelopeViewPointAttack] = CGPointMake(attackWidth, 0);
    _points[JFSEnvelopeViewPointDecay] = CGPointMake(_points[JFSEnvelopeViewPointAttack].x + decayWidth, CGRectGetHeight(self.envelopeContainer.frame) - sustainHeight);
    _points[JFSEnvelopeViewPointSustain] = CGPointMake(maxWidth * 2, CGRectGetHeight(envelopeFrame) - sustainHeight);
    _points[JFSEnvelopeViewPointRelease] = CGPointMake(_points[JFSEnvelopeViewPointSustain].x + releaseWidth, CGRectGetHeight(envelopeFrame));
    
    [path addLineToPoint:_points[JFSEnvelopeViewPointAttack]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointDecay]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointSustain]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointRelease]];
    
    if (_envelopeLayer == nil) {
        _envelopeLayer = [CAShapeLayer layer];
        _envelopeLayer.path = path.CGPath;
        _envelopeLayer.fillColor = [UIColor redColor].CGColor;
        _envelopeLayer.zPosition = 1;
        
        [self.envelopeContainer.layer addSublayer:_envelopeLayer];
    }
    
    if (_currentStageLayer == nil) {
        _currentStageLayer = [CALayer layer];
        _currentStageLayer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5].CGColor;
        _currentStageLayer.zPosition = 2;
        [self.envelopeContainer.layer addSublayer:_currentStageLayer];
    }
    
    if (self.touchPointLayers == nil) {
        self.touchPointLayers = @{@(JFSEnvelopeViewPointAttack)   : [self dotLayer],
                                  @(JFSEnvelopeViewPointDecay)    : [self dotLayer],
                                  @(JFSEnvelopeViewPointRelease)  : [self dotLayer]
                                  };
        
        [self.touchPointLayers.allValues enumerateObjectsUsingBlock:^(CAShapeLayer *dotLayer, NSUInteger idx, BOOL *stop) {
            [self.envelopeContainer.layer insertSublayer:dotLayer above:self.borderLayer];
        }];
    }
    
    [self.touchPointLayers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, CAShapeLayer *touchPointLayer, BOOL *stop) {
        [self moveTouchPointAtIndex:[key integerValue] toPoint:_points[[key integerValue]]];
    }];
}

- (void)updateStageViewWithStage:(JFSEnvelopeViewStagePoint)stage
{
    if (stage < JFSEnvelopeViewPointCount && stage >= 0) {
        
        if (stage == JFSEnvelopeViewPointAttack) {
            self.currentStageLayer.frame = CGRectMake(0, 0, _points[stage].x, self.envelopeContainer.frame.size.height);
        } else if (stage < JFSEnvelopeViewPointRelease) {
            self.currentStageLayer.frame = CGRectMake(_points[stage - 1].x, 0, _points[stage].x - _points[stage - 1].x, self.envelopeContainer.frame.size.height);
        } else {
            self.currentStageLayer.frame = CGRectMake(_points[stage - 1].x, 0, self.envelopeContainer.frame.size.width - _points[stage - 1].x, self.envelopeContainer.frame.size.height);
        }
    } else {
        self.currentStageLayer.frame = CGRectZero;
    }
}

#pragma mark - touch tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint locationInView = [touch locationInView:self.envelopeContainer];
    
    for (int i = 0; i <= JFSEnvelopeViewPointRelease; i++) {
        
        if (i == JFSEnvelopeViewPointSustain) {
            continue;
        }
        
        CGPoint point = _points[i];
        
        CGRect touchArea = CGRectMake(point.x - TOUCH_POINTS_RADIUS,
                                      point.y - TOUCH_POINTS_RADIUS,
                                      TOUCH_POINTS_RADIUS * 2,
                                      TOUCH_POINTS_RADIUS * 2);
        
        if (CGRectContainsPoint(touchArea, locationInView)) {
            self.currentPoint = i;
            _isMoving = YES;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_isMoving) {
        _points[self.currentPoint] = [self pointForTouch:touch];
        
        [self moveTouchPointAtIndex:self.currentPoint toPoint:_points[self.currentPoint]];
        
        self.envelopeLayer.path = [self pathForCurrentStagePoints].CGPath;
        
        CGPoint adjustedPoint = [self adjustedStagePointAtIndex:self.currentPoint];
        CGFloat width = CGRectGetWidth(self.envelopeContainer.frame);
        CGFloat timeValue = (adjustedPoint.x / (width/3)) * [self.dataSource maxEnvelopeTimeForEnvelopeView:self];
        
        [self.delegate envelopeView:self didUpdateEnvelopePoint:self.currentPoint value:timeValue];
        
        if (self.currentPoint == JFSEnvelopeViewPointDecay) {
            CGFloat height = CGRectGetHeight(self.envelopeContainer.frame);
            
            [self.delegate envelopeView:self didUpdateEnvelopePoint:JFSEnvelopeViewPointSustain value:((height - adjustedPoint.y) / height)];
        }
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _isMoving = NO;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    _isMoving = NO;
}

#pragma mark - touch tracking helpers

- (UIBezierPath *)pathForCurrentStagePoints
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.envelopeContainer.frame))];
    
    for (int i = 0; i < JFSEnvelopeViewPointCount; i++) {
        [path addLineToPoint:_points[i]];
    }
    return path;
}

- (CGPoint)pointForTouch:(UITouch *)touch
{
    CGPoint locationInView = [touch locationInView:self];
    
    locationInView.x = MIN(locationInView.x, CGRectGetWidth(self.envelopeContainer.frame));
    locationInView.x = MAX(locationInView.x, 0);
    locationInView.y = MIN(locationInView.y, CGRectGetHeight(self.envelopeContainer.frame));
    locationInView.y = MAX(locationInView.y, 0);
    
    switch (self.currentPoint) {
        case JFSEnvelopeViewPointAttack:
        {
            locationInView.y = 0;
            
            if (locationInView.x > ATTACK_X_RIGHT_BOUND) {
                locationInView.x = ATTACK_X_RIGHT_BOUND;
            }
            
            if (locationInView.x > _points[JFSEnvelopeViewPointDecay].x) {
                _points[JFSEnvelopeViewPointDecay].x = locationInView.x;
                
                [self moveTouchPointAtIndex:JFSEnvelopeViewPointDecay toPoint:_points[JFSEnvelopeViewPointDecay]];
            }
        }
            break;
        case JFSEnvelopeViewPointDecay:
        {
            //keep sustain and decay the same y
            _points[JFSEnvelopeViewPointSustain].y = _points[JFSEnvelopeViewPointDecay].y = locationInView.y;
            if (locationInView.x < _points[JFSEnvelopeViewPointAttack].x) {
                locationInView.x = _points[JFSEnvelopeViewPointAttack].x;
            }
            
            if (locationInView.x > _points[JFSEnvelopeViewPointAttack].x + [self maxSegmentWidth]) {
                locationInView.x = _points[JFSEnvelopeViewPointAttack].x + [self maxSegmentWidth];
            }
        }
            break;
        case JFSEnvelopeViewPointRelease:
        {
            locationInView.y = CGRectGetHeight(self.envelopeContainer.frame);
            
            if (locationInView.x < RELEASE_X_LEFT_BOUND) {
                locationInView.x = RELEASE_X_LEFT_BOUND;
            }
        }
            break;
        default:
            break;
    }
    
    return locationInView;
}

- (CGPoint)adjustedStagePointAtIndex:(JFSEnvelopeViewStagePoint)pointIdx
{
    //adjust x value so 0-10 values are reported back to delegate
    
    CGPoint adjustedPoint = _points[pointIdx];
    
    switch (pointIdx) {
        case JFSEnvelopeViewPointAttack:
            break;
        case JFSEnvelopeViewPointDecay:
            adjustedPoint.x = adjustedPoint.x - _points[JFSEnvelopeViewPointAttack].x;
            break;
        case JFSEnvelopeViewPointRelease:
            adjustedPoint.x = adjustedPoint.x - ([self maxSegmentWidth] * 2);
            break;
        default:
            break;
    }
    return adjustedPoint;
}

- (void)moveTouchPointAtIndex:(JFSEnvelopeViewStagePoint)touchPointIdx toPoint:(CGPoint)point
{
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(point.x - TOUCH_POINTS_RADIUS,
                                                              point.y - TOUCH_POINTS_RADIUS,
                                                              TOUCH_POINTS_RADIUS * 2,
                                                              TOUCH_POINTS_RADIUS * 2),
                                                   &_touchPointsTransform);
    [self.touchPointLayers[@(touchPointIdx)] setPath:path];
    
    CGPathRelease(path);
}

#pragma mark - UI Elements

- (CAShapeLayer *)dotLayer
{
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    
    dotLayer.strokeColor = [UIColor redColor].CGColor;
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(CGPointZero.x,
                                                              CGPointZero.y,
                                                              TOUCH_POINTS_RADIUS * 2,
                                                              TOUCH_POINTS_RADIUS * 2),
                                                   &_touchPointsTransform);
    dotLayer.path = path;
    
    CGPathRelease(path);
    
    dotLayer.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:0.8].CGColor;
    dotLayer.zPosition = 2;
    
    return dotLayer;
}

- (CGFloat)maxSegmentWidth
{
    return CGRectGetWidth(self.envelopeContainer.frame) / 3;
}

@end
