//
//  JFSEnvelopeView.m
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeView.h"

NS_ENUM(NSInteger, JFSEnvelopeViewSegmentPoint) {
    JFSEnvelopeViewPointAttack,
    JFSEnvelopeViewPointDecay,
    JFSEnvelopeViewPointRelease,
    JFSEnvelopeViewPointEnvelopeEnd,
    
    JFSEnvelopeViewPointCount
};

@interface JFSEnvelopeView ()
{
    CGPoint _points[JFSEnvelopeViewPointCount];
    int _currentPoint;
    BOOL _isMoving;
}

@property (nonatomic, strong) CAShapeLayer *envelopeLayer;

@end

@implementation JFSEnvelopeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (void)setDataSource:(id<JFSEnvelopeViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.frame))];
    
    //TODO set these points via datasource
    
    CGFloat maxWidth = CGRectGetWidth(self.frame) / 3;
    CGFloat maxTime = 10.0f;
    
    CGFloat attackWidth = ([_dataSource attackTime] / maxTime) * maxWidth;
    CGFloat decayWidth = ([_dataSource decayTime] / maxTime) * maxWidth;
    CGFloat releaseWidth = ([_dataSource releaseTime] / maxTime) * maxWidth;
    CGFloat sustainWidth = CGRectGetWidth(self.frame) - attackWidth - decayWidth - releaseWidth;
    
    CGFloat sustainHeight = [_dataSource sustainPercentageOfPeak] * CGRectGetHeight(self.frame);
    
    _points[0] = CGPointMake(attackWidth, 0);
    _points[1] = CGPointMake(_points[0].x + decayWidth, CGRectGetHeight(self.frame) - sustainHeight);
    _points[2] = CGPointMake(_points[1].x + sustainWidth, CGRectGetHeight(self.frame) - sustainHeight);
    _points[3] = CGPointMake(_points[2].x + releaseWidth, CGRectGetHeight(self.frame));
    
    [path addLineToPoint:_points[0]];
    [path addLineToPoint:_points[1]];
    [path addLineToPoint:_points[2]];
    [path addLineToPoint:_points[3]];
    
    _envelopeLayer = [CAShapeLayer layer];
    _envelopeLayer.path = path.CGPath;
    _envelopeLayer.fillColor = [UIColor redColor].CGColor;
    
    [self.layer addSublayer:_envelopeLayer];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.userInteractionEnabled = YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (int i = 0; i < JFSEnvelopeViewPointCount; i++) {
        
        CGPoint point = _points[i];
        
        CGRect touchArea = CGRectMake(point.x - 10, point.y - 10, 30, 30);
        
        CGPoint locationInView = [touch locationInView:self];
        
        if (CGRectContainsPoint(touchArea, locationInView)) {
            _currentPoint = i;
            _isMoving = YES;
            return YES;
        }
    }
    
    return NO;
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
        }
        
        //check if moving before previous point
        if (_currentPoint > JFSEnvelopeViewPointAttack) {
            CGPoint previousPoint = _points[_currentPoint - 1];
            
            if (previousPoint.x > locationInView.x) {
                locationInView.x = previousPoint.x;
            }
        }
        
        //check if moving past next point
        if (_currentPoint < JFSEnvelopeViewPointEnvelopeEnd) {
            CGPoint nextPoint = _points[_currentPoint + 1];
            
            if (nextPoint.x < locationInView.x) {
                locationInView.x = nextPoint.x;
            }
        }
        
        _points[_currentPoint] = locationInView;
        
        //keep sustain and release y the same
        if (_currentPoint == JFSEnvelopeViewPointDecay || _currentPoint == JFSEnvelopeViewPointRelease) {
            _points[JFSEnvelopeViewPointRelease].y = _points[JFSEnvelopeViewPointDecay].y = locationInView.y;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
        
        for (int i = 0; i < JFSEnvelopeViewPointCount; i++) {
            [path addLineToPoint:_points[i]];
        }
        
        self.envelopeLayer.path = path.CGPath;
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

@end
