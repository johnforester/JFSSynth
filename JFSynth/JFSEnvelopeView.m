//
//  JFSEnvelopeView.m
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeView.h"

#define ATTACK_X_RIGHT_BOUND CGRectGetWidth(self.frame) / 3
#define RELEASE_X_LEFT_BOUND (CGRectGetWidth(self.frame) / 3) * 2
#define TOUCH_POINTS_RADIUS 10

@interface JFSEnvelopeView ()
{
    CGPoint _points[JFSEnvelopeViewPointCount];
    CGAffineTransform _touchPointsTransform;
    int _currentPoint;
    BOOL _isMoving;
}

@property (nonatomic, strong) CAShapeLayer *envelopeLayer;
@property (nonatomic, strong) NSDictionary *touchPointLayers;

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

- (void)setUpView
{
    _touchPointsTransform = CGAffineTransformMakeRotation(2 * M_PI);
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)setDataSource:(id<JFSEnvelopeViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self refreshView];
}

- (void)refreshView
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame))];
    
    CGFloat maxWidth = [self maxSegmentWidth];
    CGFloat maxTime = [_dataSource maxEnvelopeTime];
    
    CGFloat attackWidth = ([_dataSource attackTime] / maxTime) * maxWidth;
    CGFloat decayWidth = ([_dataSource decayTime] / maxTime) * maxWidth;
    CGFloat releaseWidth = ([_dataSource releaseTime] / maxTime) * maxWidth;
    
    CGFloat sustainHeight = [_dataSource sustainPercentageOfPeak] * CGRectGetHeight(self.frame);
    
    _points[JFSEnvelopeViewPointAttack] = CGPointMake(attackWidth, 0);
    _points[JFSEnvelopeViewPointDecay] = CGPointMake(_points[JFSEnvelopeViewPointAttack].x + decayWidth, CGRectGetHeight(self.frame) - sustainHeight);
    _points[JFSEnvelopeViewPointSustainEnd] = CGPointMake(maxWidth * 2, CGRectGetHeight(self.frame) - sustainHeight);
    _points[JFSEnvelopeViewPointRelease] = CGPointMake(_points[JFSEnvelopeViewPointSustainEnd].x + releaseWidth, CGRectGetHeight(self.frame));
    
    [path addLineToPoint:_points[JFSEnvelopeViewPointAttack]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointDecay]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointSustainEnd]];
    [path addLineToPoint:_points[JFSEnvelopeViewPointRelease]];
    
    if (_envelopeLayer == nil) {
        _envelopeLayer = [CAShapeLayer layer];
        _envelopeLayer.path = path.CGPath;
        _envelopeLayer.fillColor = [UIColor redColor].CGColor;
        _envelopeLayer.zPosition = 1;
        
        [self.layer addSublayer:_envelopeLayer];
    }
    
    if (self.touchPointLayers == nil) {
        self.touchPointLayers = @{@(JFSEnvelopeViewPointAttack)   : [self dotLayer],
                                  @(JFSEnvelopeViewPointDecay)    : [self dotLayer],
                                  @(JFSEnvelopeViewPointRelease)  : [self dotLayer]
                                  };
        
        [self.touchPointLayers.allValues enumerateObjectsUsingBlock:^(CAShapeLayer *dotLayer, NSUInteger idx, BOOL *stop) {
            [self.layer addSublayer:dotLayer];
        }];
    }
    
    [self.touchPointLayers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, CAShapeLayer *touchPointLayer, BOOL *stop) {
        [self moveTouchPointAtIndex:[key integerValue] toPoint:_points[[key integerValue]]];
    }];
}

- (CGFloat)maxSegmentWidth
{
    return CGRectGetWidth(self.frame) / 3;
}

#pragma mark - touch tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint locationInView = [touch locationInView:self];
    
    for (int i = 0; i <= JFSEnvelopeViewPointRelease; i++) {
        
        if (i == JFSEnvelopeViewPointSustainEnd) {
            continue;
        }
        
        CGPoint point = _points[i];
        
        CGRect touchArea = CGRectMake(point.x - TOUCH_POINTS_RADIUS,
                                      point.y - TOUCH_POINTS_RADIUS,
                                      TOUCH_POINTS_RADIUS * 2,
                                      TOUCH_POINTS_RADIUS * 2);
        
        if (CGRectContainsPoint(touchArea, locationInView)) {
            _currentPoint = i;
            _isMoving = YES;
            return YES;
        }
    }
    
    return NO;
}

- (void)moveTouchPointAtIndex:(JFSEnvelopeViewSegmentPoint)touchPointIdx toPoint:(CGPoint)point
{
    [self.touchPointLayers[@(touchPointIdx)] setPath:CGPathCreateWithEllipseInRect(CGRectMake(point.x - TOUCH_POINTS_RADIUS,
                                                                                              point.y - TOUCH_POINTS_RADIUS,
                                                                                              TOUCH_POINTS_RADIUS * 2,
                                                                                              TOUCH_POINTS_RADIUS * 2),
                                                                                   &_touchPointsTransform)];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_isMoving) {
        CGPoint locationInView = [touch locationInView:self];
        
        locationInView.x = MIN(locationInView.x, CGRectGetWidth(self.bounds));
        locationInView.x = MAX(locationInView.x, 0);
        locationInView.y = MIN(locationInView.y, CGRectGetHeight(self.bounds));
        locationInView.y = MAX(locationInView.y, 0);
        
        if (_currentPoint == JFSEnvelopeViewPointAttack) {
            locationInView.y = 0;
            
            if (locationInView.x > ATTACK_X_RIGHT_BOUND) {
                locationInView.x = ATTACK_X_RIGHT_BOUND;
            }
            
            if (locationInView.x > _points[JFSEnvelopeViewPointDecay].x) {
                _points[JFSEnvelopeViewPointDecay].x = locationInView.x;
                
                [self moveTouchPointAtIndex:JFSEnvelopeViewPointDecay toPoint:_points[JFSEnvelopeViewPointDecay]];
            }
        }
        
        if (_currentPoint == JFSEnvelopeViewPointRelease) {
            locationInView.y = CGRectGetHeight(self.frame);
            
            if (locationInView.x < RELEASE_X_LEFT_BOUND) {
                locationInView.x = RELEASE_X_LEFT_BOUND;
            }
        }
        
        if (_currentPoint == JFSEnvelopeViewPointDecay) {
            
            if (locationInView.x < _points[JFSEnvelopeViewPointAttack].x) {
                locationInView.x = _points[JFSEnvelopeViewPointAttack].x;
            }
            
            if (locationInView.x > _points[JFSEnvelopeViewPointAttack].x + [self maxSegmentWidth]) {
                locationInView.x = _points[JFSEnvelopeViewPointAttack].x + [self maxSegmentWidth];
            }
        }
        
        _points[_currentPoint] = locationInView;
        
        //keep sustain and decay y the same
        if (_currentPoint == JFSEnvelopeViewPointDecay) {
            _points[JFSEnvelopeViewPointSustainEnd].y = _points[JFSEnvelopeViewPointDecay].y = locationInView.y;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
        
        for (int i = 0; i < JFSEnvelopeViewPointCount; i++) {
            [path addLineToPoint:_points[i]];
        }
        
        [self moveTouchPointAtIndex:_currentPoint toPoint:_points[_currentPoint]];
        
        self.envelopeLayer.path = path.CGPath;
        
        CGPoint adjustedPoint = _points[_currentPoint];
        
        switch (_currentPoint) {
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
        
        [self.delegate envelopeView:self
             didUpdateEnvelopePoint:_currentPoint
                      adjustedPoint:adjustedPoint];
        
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

#pragma mark - UI Elements

- (CAShapeLayer *)dotLayer
{
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    
    dotLayer.strokeColor = [UIColor blackColor].CGColor;
    dotLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(CGPointZero.x,
                                                             CGPointZero.y,
                                                             TOUCH_POINTS_RADIUS * 2,
                                                             TOUCH_POINTS_RADIUS * 2),
                                                  &_touchPointsTransform);
    dotLayer.fillColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.5 alpha:0.8].CGColor;
    dotLayer.zPosition = 2;
    
    return dotLayer;
}

@end
