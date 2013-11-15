//
//  JFSAudioManager.h
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFSEnvelopeGenerator;

typedef NS_ENUM(NSInteger, JFSWaveType) {
    JFSSquareWave,
    JFSSineWave,
};


@interface JFSSynthManager : NSObject

@property (nonatomic, assign) JFSWaveType waveType;

@property (nonatomic, strong) JFSEnvelopeGenerator *ampEnvelopeGenerator;

@property (nonatomic, assign) Float32 velocityPeak;

@property (nonatomic, assign) Float32 cutoffLevel;
@property (nonatomic, assign) Float32 resonanceLevel;

+ (JFSSynthManager *) sharedManager;

- (void)playFrequency:(double)frequency;
- (void)updateFrequency:(double)frequency;
- (void)stopPlaying;

- (Float32)minimumCutoff;
- (Float32)maximumCutoff;
- (Float32)minimumResonance;
- (Float32)maximumResonance;

- (Float32)minimumEnvelopeTime;
- (Float32)maximumEnvelopeTime;

@end
