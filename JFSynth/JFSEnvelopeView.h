//
//  JFSEnvelopeView.h
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JFSEnvelopeViewStagePoint) {
    JFSEnvelopeViewPointAttack,
    JFSEnvelopeViewPointDecay,
    JFSEnvelopeViewPointSustain,
    JFSEnvelopeViewPointRelease,
    
    JFSEnvelopeViewPointCount
};

@protocol JFSEnvelopeViewDataSource;
@protocol JFSEnvelopeViewDelegate;

@interface JFSEnvelopeView : UIControl

@property (nonatomic, assign) id<JFSEnvelopeViewDataSource> dataSource;
@property (nonatomic, assign) id<JFSEnvelopeViewDelegate> delegate;

- (void)updateStageViewWithStage:(JFSEnvelopeViewStagePoint)stage;
- (void)refreshView;

@end

@protocol JFSEnvelopeViewDataSource <NSObject>

@required
- (Float32)attackTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView;
- (Float32)decayTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView;
- (Float32)sustainPercentageOfPeakForEnvelopeView:(JFSEnvelopeView *)envelopeView;
- (Float32)releaseTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView;
- (Float32)maxEnvelopeTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView;

@end

@protocol JFSEnvelopeViewDelegate <NSObject>

@required
- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint value:(Float32)value;

@end