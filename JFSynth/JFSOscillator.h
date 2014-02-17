//
//  JFSOscillator.h
//  JFSynth
//
//  Created by John Forester on 11/14/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFSWaveType) {
    JFSSquareWave,
    JFSSineWave,
    JFSTriangle,
    JFSSawtooth,
};

typedef NS_ENUM(NSInteger, JFSOscillatorParam) {
    JFSOscillatorParamSemitones,
    JFSOscillatorParamFine,
    JFSOscillatorParamVolume,
};

@interface JFSOscillator : NSObject

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

- (NSNumber *)minimumValueForParameter:(JFSOscillatorParam)parameter;
- (NSNumber *)maximumValueForParameter:(JFSOscillatorParam)parameter;

@end
