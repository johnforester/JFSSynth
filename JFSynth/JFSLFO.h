//
//  JFSLFO.h
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSOscillator.h"

typedef NS_ENUM(JFSSynthParameter, JFSLFOParameter) {
    JFSLFOParameterRate,
    JFSLFOParameterAmount,
};

@interface JFSLFO : JFSOscillator

@end
