//
//  JFSAudioManager.h
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFSSynthParam) {
    JFSSynthParamCutoff,
    JFSSynthParamResonance,
    
    JFSSynthParamCutoffLFORate,
    JFSSynthParamCutoffLFOAmount,
        
    JFSSynthParamDelayDryWet,
    JFSSynthParamDelayFeedback,
    JFSSynthParamDelayTime,
    JFSSynthParamDelayCutoff,
    
    JFSSynthParamFrequency,
    JFSSynthParamVelocity,
    JFSSynthParamOscillator1Semitones,
    JFSSynthParamOscillator1Fine,
    JFSSynthParamOscillator2Semitones,
    JFSSynthParamOscillator2Fine,
    JFSSynthControllerOscillator1Volume,
    JFSSynthControllerOscillator2Volume,
    
    JFSSynthParamDistortionGain,
    JFSSynthParamDistortionMix,
};

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

- (void)playMidiNote:(int)midiNote;

- (void)setBaseFrequency:(double)frequency;
- (void)stopPlaying;

- (void)setValue:(Float32)value forParameter:(JFSSynthParam)parameter;

- (Float32)cutoffLevel;
- (Float32)resonanceLevel;
- (Float32)delayDryWet;
- (Float32)delayFeedback;
- (Float32)delayTime;
- (Float32)delayCutoff;
- (Float32)distortionGain;
- (Float32)distortionMix;

- (Float32)minimumEnvelopeTime;
- (Float32)maximumEnvelopeTime;
- (Float32)minimumVelocity;
- (Float32)maximumVelocity;

- (NSNumber *)minimumValueForParameter:(JFSSynthParam)parameter;
- (NSNumber *)maximumValueForParameter:(JFSSynthParam)parameter;

- (void)toggleDelay:(BOOL)on;
- (void)toggleDistortion:(BOOL)on;

@end
