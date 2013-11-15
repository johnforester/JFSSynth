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
};

@interface JFSOscillator : NSObject

@property (nonatomic, assign) JFSWaveType waveType;
@property (nonatomic, assign) double waveLengthInSamples;
@property (nonatomic, assign) double phase;

- (SInt16)updateOscillatorWithAmplitudeMultiplier:(Float32)multiplier;

@end