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
@property (nonatomic, assign) Float32 coarse;
@property (nonatomic, assign) Float32 fine;

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
    double frequencyWithCoarse = pow(pow(2, 1.0f/12), 24 * self.coarse) * self.baseFrequency;
    self.adjustedFrequency = pow(pow(2, 1.0f/12), self.fine) * frequencyWithCoarse;
    
    self.waveLengthInSamples = self.sampleRate / [self frequency];
}

- (void)updateBaseFrequency:(double)frequency
{
    self.baseFrequency = frequency;
    [self updateFrequencyForDetune];
}

- (void)updateCoarse:(Float32)coarse
{
    self.coarse = coarse;
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

@end
