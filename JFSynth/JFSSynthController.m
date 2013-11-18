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
@property (nonatomic, assign) Float32 lfoAmount;

@end

@implementation JFSSynthController

#define SAMPLE_RATE 44100.0

+ (JFSSynthController *)sharedManager
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
                            initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
                            inputEnabled:NO];
        
        _ampEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        _filterEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        
        _oscillator = [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE];
        
        _cutoffLFO = [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE];
        [_cutoffLFO setWaveType:JFSSineWave];
        [_cutoffLFO updateFrequency:0.0f];
        _lfoAmount = 0.0f;
        
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
    
    self.filterEnvelopeGenerator.peak = cutoffLevel;
}

- (void)adjustCutoffLevel:(Float32)adjustMultiplier
{
    AudioUnitSetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          self.cutoffLevel + adjustMultiplier,
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

- (void)setCutoffLFOFrequency:(Float32)cutoffLFOFrequency
{
    _cutoffLFOFrequency = cutoffLFOFrequency;
    
    [self.cutoffLFO updateFrequency:cutoffLFOFrequency];
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

- (Float32)minimumCutoffLFO
{
    return 0.0f;
}

- (Float32)maximumCutoffLFO
{
    return 20.0f;
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
    __block __weak JFSSynthController *weakSelf = self;
    
    _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        for (int i = 0; i < frames; i++) {
            AudioUnitSetParameter(self.lpFilter.audioUnit,
                                  kLowPassParam_CutoffFrequency,
                                  kAudioUnitScope_Global,
                                  0,
                                  [weakSelf.filterEnvelopeGenerator updateState],
                                  0);
            
            if (weakSelf.cutoffLFO.frequency > 0) {
                
                [weakSelf adjustCutoffLevel:((((Float32)[weakSelf.cutoffLFO updateOscillator] / INT16_MAX) * ((SAMPLE_RATE/2) - [self minimumCutoff]) ) +
                                             [self minimumCutoff]) * weakSelf.lfoAmount];
                
            }
            
            
            
            SInt16 sample = [weakSelf.oscillator updateOscillator] * [weakSelf.ampEnvelopeGenerator updateState];
            
            ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
            ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
        }
    }];
    
    _oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
    
    [self updateFrequency:440];
}

- (void)playFrequency:(double)frequency
{
    [self updateFrequency:frequency];
    
    [self.ampEnvelopeGenerator start];
    [self.filterEnvelopeGenerator start];
}

- (void)updateFrequency:(double)frequency
{
    [self.oscillator updateFrequency:frequency];
}

- (void)updateLFOAmount:(Float32)lfoAmount
{
    _lfoAmount = lfoAmount;
}

- (void)stopPlaying
{
    [self.ampEnvelopeGenerator stop];
    [self.filterEnvelopeGenerator stop];
}

@end
