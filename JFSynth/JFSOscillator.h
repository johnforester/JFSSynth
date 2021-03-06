//
//  JFSOscillator.h
//  JFSynth
//
//  Created by John Forester on 11/14/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFSSynthComponent.h"

typedef NS_ENUM(NSInteger, JFSWaveType) {
    JFSSquareWave,
    JFSSineWave,
    JFSTriangle,
    JFSSawtooth,
};

typedef NS_ENUM(JFSSynthParameter, JFSOscillatorParam) {
    JFSOscillatorParamSemitones,
    JFSOscillatorParamFine,
    JFSOscillatorParamVolume,
};

@interface JFSOscillator : NSObject <JFSSynthComponent>

@property (nonatomic, assign) JFSWaveType waveType;
@property (nonatomic, readonly) double baseFrequency;
@property (nonatomic, readonly) int semitones;
@property (nonatomic, readonly) Float32 fine;
@property (nonatomic, readonly) Float32 volume;

- (instancetype)initWithSampleRate:(Float32)sampleRate;

- (SInt16)updateOscillator;
- (void)updateBaseFrequency:(double)frequency;
- (void)updateSemitone:(int)semitones;
- (void)updateFine:(Float32)fine;
- (void)updateVolume:(Float32)volume;

@end
