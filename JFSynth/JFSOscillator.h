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
@property (nonatomic, readonly) double baseFrequency;
@property (nonatomic, assign) double coarseAmount;

- (instancetype)initWithSampleRate:(Float32)sampleRate;

- (SInt16)updateOscillator;
- (void)updateBaseFrequency:(double)frequency;
- (void)updateCoarse:(Float32)coarse;

@end
