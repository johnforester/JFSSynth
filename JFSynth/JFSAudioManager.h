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

@property (nonatomic, assign) JFSWaveType waveType;

@property (nonatomic, readonly) Float32 maxAmp;

@property (nonatomic, readonly) Float32 attackTime;
@property (nonatomic, readonly) Float32 decayTime;
@property (nonatomic, readonly) Float32 sustainAmount;
@property (nonatomic, readonly) Float32 releaseTime;

+ (JFSAudioManager *) sharedManager;
- (void)playFrequency:(double)frequency;
- (void)stopPlaying;

- (void)updateAttackTime:(Float32)attackAmount;
- (void)updateDecayTime:(Float32)decayAmount;
- (void)updateSustainAmount:(Float32)sustainAmount;
- (void)updateReleaseTime:(Float32)releaseAmount;

@end
