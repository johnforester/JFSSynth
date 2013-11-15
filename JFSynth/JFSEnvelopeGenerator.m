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
        
        _attackTime = 1.0;
        _decayTime = 3.0;
        _sustainLevel = _peak;
        _releaseTime = 5.0;
        
        _sampleRate = sampleRate;
        
        [self updateAttackSlope];
        [self updateDecaySlope];
        [self updateReleaseSlope];
    }
    
    return self;
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

- (void)setSustainLevel:(Float32)sustainLevel
{
    //TODO clean this up, it is confusing
    
    _sustainLevel = (sustainLevel/127. * self.peak);
    
    [self updateDecaySlope];
    [self updateReleaseSlope];
}

- (void)setPeak:(Float32)peak
{
    //TODO clean this up

    _peak = 0.4 * pow(peak/127., 3.);
    
    self.sustainLevel = _sustainLevel;
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
