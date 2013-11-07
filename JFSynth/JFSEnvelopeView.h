//
//  JFSEnvelopeView.h
//  JFSynth
//
//  Created by John Forester on 11/1/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFSEnvelopeViewDataSource <NSObject>

@required
- (Float32)attackTime;
- (Float32)decayTime;
- (Float32)sustainPercentageOfPeak;
- (Float32)releaseTime;

@end

@interface JFSEnvelopeView : UIControl

@property (nonatomic, assign) id<JFSEnvelopeViewDataSource> dataSource;

@end
