//
//  JFSAudioManager.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSSynthController.h"
#import "TheAmazingAudioEngine.h"
#import "JFSEnvelopeGenerator.h"
#import "JFSOscillator.h"

@interface JFSSynthController ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;
@property (nonatomic, strong) AEAudioUnitFilter *lpFilter;

@end

@implementation JFSSynthController

#define ENABLE_SYNTH 0

#define SAMPLE_RATE 44100.0

+ (JFSSynthController *) sharedManager
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
        
        _ampEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        _oscillator = [[JFSOscillator alloc] init];
        
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
    return 8.0f;
}

#pragma setup methods

- (void)setUpOscillatorChannel
{
    __weak JFSSynthController *weakSelf = self;

    _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        for (int i = 0; i < frames; i++) {
            
            SInt16 sample = [weakSelf.oscillator updateOscillatorWithAmplitudeMultiplier:[weakSelf.ampEnvelopeGenerator updateState]];
        
            ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
            ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
         
        }
    }];
    
    _oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
}

- (void)playFrequency:(double)frequency
{
    [self updateFrequency:frequency];
    
    [self.ampEnvelopeGenerator start];
}

- (void)updateFrequency:(double)frequency
{
    self.oscillator.waveLengthInSamples = SAMPLE_RATE / frequency;
}

- (void)stopPlaying
{
    [self.ampEnvelopeGenerator stop];
}

@end
