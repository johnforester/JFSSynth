//
//  JFSEnvelopeView.m
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeView.h"

NS_ENUM(NSInteger, JFSEnvelopeViewSegment) {
    JFSEnvelopeViewSegmentAttack,
    JFSEnvelopeViewSegmentDecay,
    JFSEnvelopeViewSegmentSustain,
    JFSEnvelopeViewSegmentRelease,
    JFSEnvelopeViewSegmentEnvelopeEnd,
    
    JFSEnvelopeViewSegmentCount
};

@interface JFSEnvelopeView ()
{
    CGPoint _points[JFSEnvelopeViewSegmentCount];
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
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(frame))];
        
        //TODO set these points via datasource
        
        _points[0] = CGPointMake((CGRectGetWidth(frame)/4), 0);
        _points[1] = CGPointMake((CGRectGetWidth(frame)/4) * 2, 30);
        _points[2] = CGPointMake((CGRectGetWidth(frame)/4) * 3, 40);
        _points[3] = CGPointMake(((CGRectGetWidth(frame)/4) * 3) + 10, 40);
        _points[4] = CGPointMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        [path addLineToPoint:_points[0]];
        [path addLineToPoint:_points[1]];
        [path addLineToPoint:_points[2]];
        [path addLineToPoint:_points[3]];
        [path addLineToPoint:_points[4]];
        
        _envelopeLayer = [CAShapeLayer layer];
        _envelopeLayer.path = path.CGPath;
        _envelopeLayer.fillColor = [UIColor redColor].CGColor;
        
        [self.layer addSublayer:_envelopeLayer];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (int i = 0; i < JFSEnvelopeViewSegmentCount - 1; i++) {
        
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
        
        if (_currentPoint == JFSEnvelopeViewSegmentAttack) {
            locationInView.y = 0;
        }
        
        //check if moving before previous point
        if (_currentPoint > JFSEnvelopeViewSegmentAttack) {
            CGPoint previousPoint = _points[_currentPoint - 1];
            
            if (previousPoint.x > locationInView.x) {
                locationInView.x = previousPoint.x;
            }
        }
        
        //check if moving past next point
        if (_currentPoint < JFSEnvelopeViewSegmentCount) {
            CGPoint nextPoint = _points[_currentPoint + 1];
            
            if (nextPoint.x < locationInView.x) {
                locationInView.x = nextPoint.x;
            }
        }
        
        _points[_currentPoint] = locationInView;
        
        //keep sustain and release y the same
        if (_currentPoint == JFSEnvelopeViewSegmentSustain || _currentPoint == JFSEnvelopeViewSegmentRelease) {
            _points[JFSEnvelopeViewSegmentRelease].y = _points[JFSEnvelopeViewSegmentSustain].y = locationInView.y;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
        
        for (int i = 0; i < JFSEnvelopeViewSegmentCount; i++) {
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
