//
//  JFSAudioManager.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSSynthManager.h"
#import "TheAmazingAudioEngine.h"
#import "JFSEnvelopeGenerator.h"

@interface JFSSynthManager ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;
@property (nonatomic, strong) AEAudioUnitFilter *lpFilter;

@property (nonatomic, assign) double waveLengthInSamples;

@end

@implementation JFSSynthManager

#define ENABLE_SYNTH 0

#define SAMPLE_RATE 44100.0

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
        
        _ampEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        
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
    __weak JFSSynthManager *weakSelf = self;
    
    __block SInt16 phase = 0;
    
    _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        for (int i = 0; i < frames; i++) {
            
            Float32 amp = [weakSelf.ampEnvelopeGenerator updateState];
            
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
            
            if (weakSelf.ampEnvelopeGenerator.envelopeState != JFSEnvelopeStateNone) {
                sample *= amp;
                
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
    self.ampEnvelopeGenerator.envelopeState = JFSEnvelopeStateAttack;
    
    [self updateFrequency:frequency];
    self.ampEnvelopeGenerator.level = 0;
}

- (void)updateFrequency:(double)frequency
{
    self.waveLengthInSamples = SAMPLE_RATE / frequency;
}

- (void)stopPlaying
{
    self.ampEnvelopeGenerator.envelopeState = JFSEnvelopeStateRelease;
}



@end
