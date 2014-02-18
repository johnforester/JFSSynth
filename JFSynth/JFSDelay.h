//
//  JFSDelay.h
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSAUFilter.h"

typedef NS_ENUM(JFSSynthParameter, JFSDelayParameter) {
    JFSDelayParamDryWet,
    JFSDelayParamFeedback,
    JFSDelayParamTime,
    JFSDelayParamCutoff,
};

@interface JFSDelay : JFSAUFilter

@end
