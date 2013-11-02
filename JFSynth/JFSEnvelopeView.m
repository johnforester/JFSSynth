//
//  JFSEnvelopeView.m
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeView.h"

@interface JFSEnvelopeView ()

@property (nonatomic, strong) CAShapeLayer *envelopeLayer;

@end

@implementation JFSEnvelopeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(frame))];
        
        [path addLineToPoint:CGPointMake((CGRectGetWidth(frame)/4), 20)];
        [path addLineToPoint:CGPointMake((CGRectGetWidth(frame)/4) * 2, 30)];
        [path addLineToPoint:CGPointMake((CGRectGetWidth(frame)/4) * 3, 40)];
        [path addLineToPoint:CGPointMake(((CGRectGetWidth(frame)/4) * 3) + 10, 40)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        _envelopeLayer = [CAShapeLayer layer];
        _envelopeLayer.path = path.CGPath;
        _envelopeLayer.fillColor = [UIColor redColor].CGColor;
        
        [self.layer addSublayer:_envelopeLayer];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
    
    return self;
}

@end
