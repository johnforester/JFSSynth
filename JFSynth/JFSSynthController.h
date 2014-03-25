//
//  JFSAudioManager.h
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFSSynthComponent.h"

typedef NS_ENUM(JFSSynthParameter, JFSSynthControllerParameter) {
    JFSSynthParamFrequency,
    JFSSynthParamVelocity,
};

@class JFSEnvelopeGenerator, JFSOscillator, JFSLowPassFilter, JFSLFO, JFSDelay, JFSDistortion;

@interface JFSSynthController : NSObject

@property (nonatomic, strong) JFSEnvelopeGenerator *ampEnvelopeGenerator;
@property (nonatomic, strong) JFSEnvelopeGenerator *filterEnvelopeGenerator;

@property (nonatomic, readonly) NSArray *oscillators;
@property (nonatomic, readonly) JFSLowPassFilter *lpFilter;
@property (nonatomic, readonly) JFSLFO *cutoffLFO;
@property (nonatomic, readonly) JFSDelay *delay;
@property (nonatomic, readonly) JFSDistortion *distortion;

@property (nonatomic, assign) Float32 velocityPeak;


+ (JFSSynthController *) sharedController;

- (void)playMidiNote:(int)midiNote;

- (void)setBaseFrequency:(double)frequency;
- (void)stopPlaying;

- (Float32)outputLevel;

- (Float32)minimumEnvelopeTime;
- (Float32)maximumEnvelopeTime;
- (Float32)minimumVelocity;
- (Float32)maximumVelocity;

- (void)toggleDelay:(BOOL)on;
- (void)toggleDistortion:(BOOL)on;

@end
