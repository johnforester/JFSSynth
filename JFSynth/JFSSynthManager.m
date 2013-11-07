//
//  JFSAudioManager.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSSynthManager.h"
#import "TheAmazingAudioEngine.h"

typedef NS_ENUM(NSInteger, JFSEnvelopeState) {
    JFSEnvelopeStateNone,
    JFSEnvelopeStateAttack,
    JFSEnvelopeStateSustain,
    JFSEnvelopeStateDecay,
    JFSEnvelopeStateRelease,
};

@interface JFSSynthManager ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;
@property (nonatomic, strong) AEAudioUnitFilter *lpFilter;

@property (nonatomic, assign) double waveLengthInSamples;

@property (nonatomic, assign) Float32 amp;

@property (nonatomic, assign) Float32 attackSlope;
@property (nonatomic, assign) Float32 decaySlope;
@property (nonatomic, assign) Float32 releaseSlope;

@property (nonatomic, assign) JFSEnvelopeState envelopeState;

@end

@implementation JFSSynthManager

#define ENABLE_SYNTH 0

#define SAMPLE_RATE 44100.0
#define VOLUME 0.1

+ (JFSSynthManager *) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
#ifdef ENABLE_SYNTH
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#endif
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
                            inputEnabled:NO];
        
        [self setUpAmpEnvelope];
        [self setUpOscillatorChannel];
        
        AudioComponentDescription lpFilterComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                      kAudioUnitType_Effect,
                                                                                      kAudioUnitSubType_LowPassFilter);
        
        NSError *error = nil;
        
        self.lpFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:lpFilterComponent
                                                                              audioController:_audioController
                                                                                        error:&error];

        if (!self.lpFilter) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        }
        
        self.cutoffLevel = 6200.0f;
        self.resonanceLevel = 0.0;
        
        [_audioController addChannels:@[_oscillatorChannel]];
        [_audioController addFilter:self.lpFilter];
        
        error = nil;
        
        if (![_audioController start:&error]) {
            NSLog(@"AudioController start error: %@", [error localizedDescription]);
        }
    }
    
    return self;
}

#pragma accessor methods

//TODO set limits

- (void)setMaxMidiVelocity:(Float32)maxMidiVelocity
{
    _maxMidiVelocity = maxMidiVelocity;
    self.velocityPeak = 0.4 * pow(maxMidiVelocity/127., 3.);
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
    _sustainLevel = 0.4 * pow(sustainLevel/127., 3.);
    
    [self updateDecaySlope];
    [self updateReleaseSlope];
}

- (void)setReleaseTime:(Float32)releaseTime
{
    _releaseTime = releaseTime;
    
    [self updateReleaseSlope];
}

- (void)setCutoffLevel:(Float32)cutoffLevel
{
    _cutoffLevel = cutoffLevel;
        
    AudioUnitSetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          cutoffLevel,
                          0);
}

- (void)setResonanceLevel:(Float32)resonanceLevel
{
    _resonanceLevel = resonanceLevel;
    
    AudioUnitSetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_Resonance,
                          kAudioUnitScope_Global,
                          0,
                          resonanceLevel,
                          0);
}

- (Float32)minimumCutoff
{
    return 10.0f;
}

- (Float32)maximumCutoff
{
    return SAMPLE_RATE/2.0f;
}

- (Float32)minimumResonance
{
    return -20.0f;
}

- (Float32)maximumResonance
{
    return 40.0f;
}

- (Float32)minimumEnvelopeTime
{
    return 0.0001f;
}

- (Float32)maximumEnvelopeTime
{
    return 10.0f;
}

#pragma setup methods

- (void)setUpAmpEnvelope
{
    self.amp = 0;
    self.maxMidiVelocity = 127;
    
    self.attackTime = 1.0;
    self.decayTime = 3.0;
    self.sustainLevel = self.maxMidiVelocity;
    self.releaseTime = 5.0;
}

- (void)setUpOscillatorChannel
{
    __weak JFSSynthManager *weakSelf = self;
    
    __block SInt16 phase = 0;
    
    _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        for (UInt32 i = 0; i < frames; i++) {
            switch (self.envelopeState) {
                case JFSEnvelopeStateAttack:
                    if (weakSelf.amp < weakSelf.velocityPeak) {
                        weakSelf.amp += weakSelf.attackSlope;
                    } else {
                        weakSelf.envelopeState = JFSEnvelopeStateDecay;
                    }
                    break;
                case JFSEnvelopeStateDecay:
                    if (weakSelf.amp > weakSelf.sustainLevel) {
                        weakSelf.amp += weakSelf.decaySlope;
                    } else {
                        weakSelf.envelopeState = JFSEnvelopeStateSustain;
                    }
                    break;
                case JFSEnvelopeStateRelease:
                    if (weakSelf.amp > 0.0) {
                        weakSelf.amp += weakSelf.releaseSlope;
                    } else {
                        weakSelf.envelopeState = JFSEnvelopeStateNone;
                    }
                    break;
                default:
                    break;
            }
            
            SInt16 sample;
            
            switch (weakSelf.waveType)
            {
                case JFSSquareWave:
                    if (phase < weakSelf.waveLengthInSamples / 2) {
                        sample = INT16_MAX;
                    } else {
                        sample = INT16_MIN;
                    }
                    break;
                case JFSSineWave:
                    sample = INT16_MAX * sin(2 * M_PI * (phase / weakSelf.waveLengthInSamples));
                    break;
                default:
                    break;
            }
            
            if (weakSelf.envelopeState != JFSEnvelopeStateNone) {
               sample *= weakSelf.amp;
                
                ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
                ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
                
                phase++;
                
                if (phase > weakSelf.waveLengthInSamples) {
                    phase -= weakSelf.waveLengthInSamples;
                }
            }
        }
    }];
    
    _oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
}

- (void)playFrequency:(double)frequency
{
    self.envelopeState = JFSEnvelopeStateAttack;
    
    self.waveLengthInSamples = SAMPLE_RATE / frequency;
    self.amp = 0;
}

- (void)stopPlaying
{
    self.envelopeState = JFSEnvelopeStateRelease;
}

#pragma mark - envelope updates

- (void)updateAttackSlope
{
    self.attackSlope = self.velocityPeak / (self.attackTime * SAMPLE_RATE);
}

- (void)updateDecaySlope
{
    self.decaySlope = -(self.velocityPeak - self.sustainLevel) / (self.decayTime * SAMPLE_RATE);
}

- (void)updateReleaseSlope
{
    self.releaseSlope = -self.velocityPeak / (self.releaseTime * SAMPLE_RATE);
}

@end
