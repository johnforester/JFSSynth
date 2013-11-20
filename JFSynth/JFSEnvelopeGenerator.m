//
//  JFSEnvelopeGenerator.m
//  JFSynth
//
//  Created by John Forester on 11/14/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSEnvelopeGenerator.h"

@interface JFSEnvelopeGenerator ()

@property (nonatomic, assign) Float32 attackSlope;
@property (nonatomic, assign) Float32 decaySlope;
@property (nonatomic, assign) Float32 releaseSlope;

@end

@implementation JFSEnvelopeGenerator

- (instancetype)initWithSampleRate:(Float32)sampleRate
{
    self = [super init];
    
    if (self) {
        
        _level = 0;
        _peak = 0.4 * pow(60/127., 3.);
        _attackTime = 0.0f;
        _decayTime = 3.0;
        _sustainLevel = _peak/2;
        _releaseTime = 1.0;
        _sampleRate = sampleRate;
        
        [self updateAttackSlope];
        [self updateDecaySlope];
        [self updateReleaseSlope];
    }
    
    return self;
}

- (void)start
{
    self.envelopeState = JFSEnvelopeStateAttack;
    self.level = 0;
}

- (void)stop
{
    self.envelopeState = JFSEnvelopeStateRelease; 
}

- (Float32)updateState
{
    switch (self.envelopeState) {
        case JFSEnvelopeStateAttack:
            if (self.level < self.peak) {
                self.level += self.attackSlope;
            } else {
                self.envelopeState = JFSEnvelopeStateDecay;
            }
            break;
        case JFSEnvelopeStateDecay:
            if (self.level > self.sustainLevel) {
                self.level += self.decaySlope;
            } else {
                self.envelopeState = JFSEnvelopeStateSustain;
            }
            break;
        case JFSEnvelopeStateRelease:
            if (self.level > 0.0) {
                self.level += self.releaseSlope;
            } else {
                self.envelopeState = JFSEnvelopeStateNone;
            }
            break;
        default:
            break;
    }
    
    return self.level;
}

- (void)setAttackTime:(Float32)attackTime
{
    _attackTime = attackTime;
    [self updateAttackSlope];
}

- (void)setDecayTime:(Float32)decayTime
{
    _decayTime = decayTime;
    [self updateDecaySlope];
}

- (void)updateSustainWithMidiVelocity:(short)midiVelocity
{
    self.sustainLevel = (midiVelocity/127. * self.peak);
}

- (void)setSustainLevel:(Float32)sustainLevel
{
    _sustainLevel = sustainLevel;
    
    [self updateDecaySlope];
    [self updateReleaseSlope];
}

- (void)updatePeakWithMidiVelocity:(short)midiVelocity
{
    self.peak = 0.4 * pow(midiVelocity/127., 3.);
}

- (void)setPeak:(Float32)peak
{
    Float32 oldPeak = _peak;
    
    _peak = peak;

    Float32 sustainPercentageOfVelocity = _sustainLevel / oldPeak;

    self.level += (peak - oldPeak);
    self.sustainLevel = _peak * sustainPercentageOfVelocity;
    
    [self updateAttackSlope];
    [self updateDecaySlope];
    [self updateReleaseSlope];
}

- (void)setReleaseTime:(Float32)releaseTime
{
    _releaseTime = releaseTime;
    
    [self updateReleaseSlope];
}

#pragma mark - envelope updates

- (void)updateAttackSlope
{
    if (self.attackTime > 0.0f) {
        self.attackSlope = self.peak / (self.attackTime * self.sampleRate);
    } else {
        self.attackSlope = self.peak;
    }
}

- (void)updateDecaySlope
{
    if (self.decayTime > 0.0f) {
        self.decaySlope = -(self.peak - self.sustainLevel) / (self.decayTime * self.sampleRate);
    } else {
        self.decaySlope = -self.sustainLevel;
    }
}

- (void)updateReleaseSlope
{
    self.releaseSlope = -self.sustainLevel / (self.releaseTime * self.sampleRate);
}

@end
