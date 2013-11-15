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
        _peak = 0.4 * pow(60/127., 3.);;
        _attackTime = 0.1;
        _decayTime = 3.0;
        _sustainLevel = _peak/2;
        _releaseTime = 5.0;
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
    __weak typeof(self) weakSelf = self;
    
    switch (self.envelopeState) {
        case JFSEnvelopeStateAttack:
            if (weakSelf.level < weakSelf.peak) {
                weakSelf.level += weakSelf.attackSlope;
            } else {
                weakSelf.envelopeState = JFSEnvelopeStateDecay;
            }
            break;
        case JFSEnvelopeStateDecay:
            if (weakSelf.level > weakSelf.sustainLevel) {
                weakSelf.level += weakSelf.decaySlope;
            } else {
                weakSelf.envelopeState = JFSEnvelopeStateSustain;
            }
            break;
        case JFSEnvelopeStateRelease:
            if (weakSelf.level > 0.0) {
                weakSelf.level += weakSelf.releaseSlope;
            } else {
                weakSelf.envelopeState = JFSEnvelopeStateNone;
            }
            break;
        default:
            break;
    }
    
    return weakSelf.level;
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
    Float32 sustainPercentageOfVelocity = _sustainLevel / _peak;
    
    self.peak = 0.4 * pow(midiVelocity/127., 3.);
    
    self.sustainLevel = self.peak * sustainPercentageOfVelocity;
}

- (void)setPeak:(Float32)peak
{
    //TODO check if sustain is greater than peak
    _peak = peak;
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
