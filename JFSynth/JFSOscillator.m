//
//  JFSOscillator.m
//  JFSynth
//
//  Created by John Forester on 11/14/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSOscillator.h"

@interface JFSOscillator ()

@property (nonatomic, assign) double phase;
@property (nonatomic, assign) double waveLengthInSamples;
@property (nonatomic, assign) double sampleRate;

@property (nonatomic, assign) double baseFrequency;
@property (nonatomic, assign) double adjustedFrequency;
@property (nonatomic, assign) Float32 semitones;
@property (nonatomic, assign) Float32 fine;
@property (nonatomic, assign) Float32 volume;

@end

@implementation JFSOscillator

- (instancetype)initWithSampleRate:(Float32)sampleRate
{
    self = [super init];
    
    if (self) {
        _sampleRate = sampleRate;
    }
    
    return self;
}

- (SInt16)updateOscillator
{
    SInt16 sample;
    
    switch (self.waveType)
    {
        case JFSSquareWave:
            if (self.phase < self.waveLengthInSamples / 2) {
                sample = INT16_MAX;
            } else {
                sample = INT16_MIN;
            }
            break;
        case JFSSineWave:
            sample = INT16_MAX * sin(2 * M_PI * (self.phase / self.waveLengthInSamples));
            break;
        case JFSTriangle:
            sample = 2.0 * (fabs(INT16_MIN + ((2.0 * (self.phase / self.waveLengthInSamples)) * INT16_MAX)) - (INT16_MAX/2));
            break;
        case JFSSawtooth:
            sample = INT16_MAX - (2.0 * (self.phase / self.waveLengthInSamples) * INT16_MAX);
            break;
        default:
            break;
    }
    
    self.phase++;
    
    if (self.phase > self.waveLengthInSamples) {
        self.phase -= self.waveLengthInSamples;
    }
    
    return sample;
}

- (void)updateFrequencyForDetune
{
    double frequencyWithSemitoneAdjustment = pow(pow(2, 1.0/12), self.semitones) * self.baseFrequency;
    self.adjustedFrequency = pow(pow(2, 1.0/12), self.fine) * frequencyWithSemitoneAdjustment;
    
    self.waveLengthInSamples = self.sampleRate / [self frequency];
}

- (void)updateBaseFrequency:(double)frequency
{
    self.baseFrequency = frequency;
    [self updateFrequencyForDetune];
}

- (void)updateSemitone:(int)semitones
{
    self.semitones = semitones;
    [self updateFrequencyForDetune];
}

- (void)updateFine:(Float32)fine
{
    self.fine = fine;
    [self updateFrequencyForDetune];
}

- (double)frequency
{
    return self.adjustedFrequency;
}

- (void)updateVolume:(Float32)volume
{
    _volume = MAX(0, volume);
    _volume = MIN(1.0, volume);
}

@end
