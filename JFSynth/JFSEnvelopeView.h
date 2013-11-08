//
//  JFSEnvelopeView.h
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JFSEnvelopeViewSegmentPoint) {
    JFSEnvelopeViewPointAttack,
    JFSEnvelopeViewPointDecay,
    JFSEnvelopeViewPointSustainEnd,
    JFSEnvelopeViewPointRelease,
    
    JFSEnvelopeViewPointCount
};

@protocol JFSEnvelopeViewDataSource;
@protocol JFSEnvelopeViewDelegate;

@interface JFSEnvelopeView : UIControl

@property (nonatomic, assign) id<JFSEnvelopeViewDataSource> dataSource;
@property (nonatomic, assign) id<JFSEnvelopeViewDelegate> delegate;

@end

@protocol JFSEnvelopeViewDataSource <NSObject>

@required
- (Float32)attackTime;
- (Float32)decayTime;
- (Float32)sustainPercentageOfPeak;
- (Float32)releaseTime;
- (Float32)maxEnvelopeTime;

@end

@protocol JFSEnvelopeViewDelegate <NSObject>

@required
- (void)envelopeView:(JFSEnvelopeView *)envelopView didUpdateEnvelopePoint:(JFSEnvelopeViewSegmentPoint)envelopePoint adjustedPoint:(CGPoint)point;

@end