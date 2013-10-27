//
//  JFSAudioManager.h
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFSWaveType) {
    JFSSquareWave,
    JFSSineWave,
};

@interface JFSAudioManager : NSObject

+ (JFSAudioManager *) sharedManager;
- (void)playFrequency:(double)frequency;

@property (nonatomic, assign) JFSWaveType waveType;

@end
