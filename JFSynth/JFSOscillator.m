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

@end

@implementation JFSOscillator

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

@end
