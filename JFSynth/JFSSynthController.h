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

@property (nonatomic, readonly) NSArray *oscillators;

@property (nonatomic, strong) JFSOscillator *cutoffLFO;

@property (nonatomic, assign) Float32 velocityPeak;

@property (nonatomic, assign) Float32 cutoffLFOFrequency;
@property (nonatomic, assign) Float32 cutoffKnobLevel;
@property (nonatomic, readonly) Float32 cuttoffLFOAmount;

+ (JFSSynthController *) sharedController;

- (void)playFrequency:(double)frequency;
- (void)playMidiNote:(int)midiNote;

- (void)setBaseFrequency:(double)frequency;
- (void)stopPlaying;

- (void)setCutoffLFOAmount:(Float32)lfoAmount;

- (void)setSemitonesForOscillatorAtIndex:(int)oscillatorIdx value:(int)semitones;
- (void)setFineForOscillatorAtIndex:(int)oscillatorIdx value:(Float32)fine;
- (void)setVolumeForOscillatorAtIndex:(int)oscillatorIdx value:(Float32)value;

- (Float32)cutoffLevel;
- (Float32)resonanceLevel;
- (void)setCutoffLevel:(Float32)cutoffLevel;
- (void)setResonanceLevel:(Float32)resonanceLevel;

- (Float32)minimumCutoff;
- (Float32)maximumCutoff;
- (Float32)minimumResonance;
- (Float32)maximumResonance;
- (Float32)minimumCutoffLFO;
- (Float32)maximumCutoffLFO;
- (Float32)minimumEnvelopeTime;
- (Float32)maximumEnvelopeTime;
- (Float32)minimumDelayDryWet;
- (Float32)maximumDelayDryWet;
- (Float32)delayDryWet;
- (Float32)minimumDelayFeedback;
- (Float32)maximumDelayFeedback;
- (Float32)delayFeedback;
- (Float32)minimumDelayTime;
- (Float32)maximumDelayTime;
- (Float32)delayTime;
- (Float32)minimumDelayCutoff;
- (Float32)maximumDelayCutoff;
- (Float32)delayCutoff;
- (Float32)minimumVelocity;
- (Float32)maximumVelocity;
- (NSInteger)minimumSemitones;
- (NSInteger)maximumSemitones;
- (Float32)minimumFine;
- (Float32)maximumFine;
- (Float32)distortionGain;
- (Float32)distortionMix;
- (Float32)maximumDistortionMix;
- (Float32)minimumDistortionMix;
- (Float32)maximumDistortionGain;
- (Float32)minimumDistortionGain;

- (void)setDelayWetDry:(Float32)level;
- (void)setDelayTime:(Float32)level;
- (void)setDelayFeedback:(Float32)level;
- (void)setDelayCutoff:(Float32)level;
- (void)setDistortionGain:(Float32)value;
- (void)setDistortionMix:(Float32)value;

@end
