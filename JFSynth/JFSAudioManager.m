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
@property (nonatomic, assign) Float32 upSlope;
@property (nonatomic, assign) Float32 downSlope;
@property (nonatomic, assign) Float32 velocity;

@property (nonatomic, assign) JFSEnvelopeState envelopeState;

@end

@implementation JFSAudioManager

#define SAMPLE_RATE 44100.0

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
        
        __weak JFSAudioManager *weakSelf = self;
        
        __block SInt16 framePosition = 0;
        
        self.amp = 0;
        self.velocity = 50;
        
        self.maxAmp = 0.4 * pow(self.velocity/127., 3.);
        
        self.upSlope = self.maxAmp / (0.9 * SAMPLE_RATE);
        self.downSlope = -self.maxAmp / (0.9 * SAMPLE_RATE);
        
        __block AudioTimeStamp *startTime;
        
        _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            for (int i = 0; i < frames; i++) {
                
                if (i == 0) {
                    startTime = (AudioTimeStamp *)time;
                }
                
                switch (self.envelopeState) {
                    case JFSEnvelopeStateAttack:
                        if (weakSelf.amp < weakSelf.maxAmp) {
                            weakSelf.amp += weakSelf.upSlope;
                        }
                        break;
                    case JFSEnvelopeStateRelease:
                        if (weakSelf.amp > 0.0) {
                            weakSelf.amp += self.downSlope;
                        }
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
                    sample *= weakSelf.amp;
                    
                    ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
                    ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
                    
                    framePosition++;
                    
                    if (framePosition > weakSelf.waveLengthInSamples) {
                        framePosition -= weakSelf.waveLengthInSamples;
                    }
                }
            }
        }];
    }
    _oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
    
    AEChannelGroupRef channelGroup = [_audioController createChannelGroup];
    
    [_audioController addChannels:@[_oscillatorChannel] toChannelGroup:channelGroup];
    
    [_audioController setAudioSessionCategory:kAudioSessionCategory_SoloAmbientSound];
    NSError *error = nil;
    
    if (![_audioController start:&error]) {
        NSLog(@"AudioController start error: %@", [error localizedDescription]);
    }
    
    return self;
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

@end
