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

+ (JFSAudioManager *) sharedManager;
- (void)playFrequency:(double)frequency;
- (void)stopPlaying;

- (void)updateAttackAmount:(CGFloat)attackAmount;
- (void)updateDecayAmount:(CGFloat)decayAmount;
- (void)updateReleaseAmount:(CGFloat)releaseAmount;

@end
