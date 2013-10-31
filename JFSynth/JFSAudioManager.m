//
//  JFSAudioManager.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSAudioManager.h"
#import "TheAmazingAudioEngine.h"

typedef NS_ENUM(NSInteger, JFSEnvelopeState) {
    JFSEnvelopeStateNone,
    JFSEnvelopeStateAttack,
    JFSEnvelopeStateSustain,
    JFSEnvelopeStateDecay,
    JFSEnvelopeStateRelease,
};

@interface JFSAudioManager ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;

@property (nonatomic, assign) double waveLengthInSamples;

@property (nonatomic, assign) Float32 amp;
@property (nonatomic, assign) Float32 maxAmp;

@property (nonatomic, assign) Float32 attackSlope;
@property (nonatomic, assign) Float32 decaySlope;
@property (nonatomic, assign) Float32 releaseSlope;

@property (nonatomic, assign) Float32 attackTime;
@property (nonatomic, assign) Float32 decayTime;
@property (nonatomic, assign) Float32 sustainAmount;
@property (nonatomic, assign) Float32 releaseTime;

@property (nonatomic, assign) Float32 maxVelocity;

@property (nonatomic, assign) JFSEnvelopeState envelopeState;

@end

@implementation JFSAudioManager

#define SAMPLE_RATE 44100.0
#define VOLUME 0.3

+ (JFSAudioManager *) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:NO];
        
        
        [self setUpAmpEnvelope];
        [self setUpOscillatorChannel];
        
        AEChannelGroupRef channelGroup = [_audioController createChannelGroup];
        [_audioController addChannels:@[_oscillatorChannel] toChannelGroup:channelGroup];
        
        [_audioController setAudioSessionCategory:kAudioSessionCategory_SoloAmbientSound];
        
        NSError *error = nil;
        
        if (![_audioController start:&error]) {
            NSLog(@"AudioController start error: %@", [error localizedDescription]);
        }
    }
    
    return self;
}

- (void)setUpAmpEnvelope
{
    self.amp = 0;
    self.maxVelocity = 70;
    
    self.maxAmp = 0.4 * pow(self.maxVelocity/127., 3.);
    self.sustainAmount = 0.4 * pow(self.maxVelocity/127., 3.);
    
    [self updateAttackTime:0.0001];
    [self updateDecayTime:10];
    [self updateReleaseTime:0.9];
}

- (void)setUpOscillatorChannel
{
    __weak JFSAudioManager *weakSelf = self;
    
    __block SInt16 framePosition = 0;
    
    _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        for (int i = 0; i < frames; i++) {
            switch (self.envelopeState) {
                case JFSEnvelopeStateAttack:
                    if (weakSelf.amp < weakSelf.maxAmp) {
                        weakSelf.amp += weakSelf.attackSlope;
                    } else {
                        weakSelf.envelopeState = JFSEnvelopeStateDecay;
                    }
                    break;
                case JFSEnvelopeStateDecay:
                    if (weakSelf.amp > weakSelf.sustainAmount) {
                        weakSelf.amp += weakSelf.decaySlope;
                    } else {
                        weakSelf.envelopeState = JFSEnvelopeStateSustain;
                        weakSelf.amp = weakSelf.sustainAmount;
                    }
                    break;
                case JFSEnvelopeStateRelease:
                    if (weakSelf.amp > 0.0) {
                        weakSelf.amp += weakSelf.releaseSlope;
                    }
                    break;
                default:
                    break;
            }
            
            SInt16 sample;
            
            switch (weakSelf.waveType)
            {
                case JFSSquareWave:
                    if (framePosition < weakSelf.waveLengthInSamples / 2) {
                        sample = SHRT_MAX;
                    } else {
                        sample = SHRT_MIN;
                    }
                    break;
                case JFSSineWave:
                    sample = (SInt16)SHRT_MAX * sin(2 * M_PI * (framePosition / weakSelf.waveLengthInSamples));
                    break;
                default:
                    break;
            }
            
            if (self.envelopeState != JFSEnvelopeStateNone) {
                sample *= weakSelf.amp * VOLUME;
                
                ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
                ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
                
                framePosition++;
                
                if (framePosition > weakSelf.waveLengthInSamples) {
                    framePosition -= weakSelf.waveLengthInSamples;
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

- (void)updateAttackTime:(Float32)attackAmount
{
    self.attackTime = attackAmount;
    self.attackSlope = self.maxAmp / (self.attackTime * SAMPLE_RATE);
}

- (void)updateDecayTime:(Float32)decayAmount
{
    self.decayTime = decayAmount;
    self.decaySlope = -(self.maxAmp - self.sustainAmount) / (self.decayTime * SAMPLE_RATE);
}

- (void)updateSustainAmount:(Float32)sustainAmount
{
    self.sustainAmount = 0.4 * pow(sustainAmount/127., 3.);
}

- (void)updateReleaseTime:(Float32)releaseAmount
{
    self.releaseTime = releaseAmount;
    self.releaseSlope = -self.sustainAmount / (self.releaseTime * SAMPLE_RATE);
}

@end
