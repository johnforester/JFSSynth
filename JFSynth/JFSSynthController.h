//
//  JFSAudioManager.h
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFSEnvelopeGenerator;
@class JFSOscillator;

@interface JFSSynthController : NSObject

@property (nonatomic, strong) JFSEnvelopeGenerator *ampEnvelopeGenerator;
@property (nonatomic, strong) JFSEnvelopeGenerator *filterEnvelopeGenerator;

@property (nonatomic, strong) JFSOscillator *oscillatorOne;
@property (nonatomic, strong) JFSOscillator *oscillatorTwo;

@property (nonatomic, strong) JFSOscillator *cutoffLFO;

@property (nonatomic, assign) Float32 velocityPeak;

@property (nonatomic, assign) Float32 cutoffLevel;
@property (nonatomic, assign) Float32 resonanceLevel;
@property (nonatomic, assign) Float32 cutoffLFOFrequency;
@property (nonatomic, readonly) Float32 cuttoffLFOAmount;

+ (JFSSynthController *) sharedManager;

- (void)playFrequency:(double)frequency;
- (void)updateFrequency:(double)frequency;
- (void)updateLFOAmount:(Float32)lfoAmount;
- (void)stopPlaying;

- (Float32)minimumCutoff;
- (Float32)maximumCutoff;
- (Float32)minimumResonance;
- (Float32)maximumResonance;
- (Float32)minimumCutoffLFO;
- (Float32)maximumCutoffLFO;

- (Float32)minimumEnvelopeTime;
- (Float32)maximumEnvelopeTime;

@end
