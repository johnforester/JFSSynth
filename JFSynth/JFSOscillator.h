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

@interface JFSOscillator : NSObject

@property (nonatomic, assign) JFSWaveType waveType;
@property (nonatomic, readonly) double baseFrequency;
@property (nonatomic, readonly) Float32 coarse;
@property (nonatomic, readonly) Float32 fine;

- (instancetype)initWithSampleRate:(Float32)sampleRate;

- (SInt16)updateOscillator;
- (void)updateBaseFrequency:(double)frequency;
- (void)updateCoarse:(Float32)coarse;
- (void)updateFine:(Float32)fine;

@end
