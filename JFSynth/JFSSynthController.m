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
@property (nonatomic, strong) AEAudioUnitFilter *delay;

@property (nonatomic, assign) Float32 cuttoffLFOAmount;
@property (nonatomic, strong) NSArray *oscillatorChannels;
@property (nonatomic, strong) NSArray *oscillators;

@end

@implementation JFSSynthController

#define SAMPLE_RATE 44100.0

+ (JFSSynthController *)sharedController
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
        
        _oscillators = @[[[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE], [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE]];
        [_oscillators[1] updateFine:0.05];
        
        [self setBaseFrequency:440];
        
        _oscillatorChannels = @[[self oscillatorChannelWithOscillator:_oscillators[0]], [self oscillatorChannelWithOscillator:_oscillators[1]]];
        [_audioController addChannels:_oscillatorChannels];
        
        _cutoffLFO = [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE];
        [_cutoffLFO setWaveType:JFSSineWave];
        [_cutoffLFO updateBaseFrequency:0.0f];
        _cuttoffLFOAmount = 0.0f;
        
        AudioComponentDescription lpFilterComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                      kAudioUnitType_Effect,
                                                                                      kAudioUnitSubType_LowPassFilter);
        
        NSError *error = nil;
        
        _lpFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:lpFilterComponent
                                                                audioController:_audioController
                                                                          error:&error];
        
        if (error) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        } else {
            [_audioController addFilter:_lpFilter];
        }
        
        self.cutoffLevel = 6200.0f;
        self.resonanceLevel = 0.0;
        
        AudioComponentDescription delayComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                      kAudioUnitType_Effect,
                                                                                      kAudioUnitSubType_Delay);
        
        error = nil;
        
        _delay = [[AEAudioUnitFilter alloc] initWithComponentDescription:delayComponent
                                                            audioController:_audioController
                                                                      error:&error];
        
        if (error) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        } else {
            [_audioController addFilter:_delay];
        }
        
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

// Global, EqPow Crossfade, 0->100, 50
- (void)setDelayWetDry:(Float32)level
{
    AudioUnitSetParameter(self.delay.audioUnit,
                          kDelayParam_WetDryMix,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

// Global, Secs, 0->2, 1
- (void)setDelayTime:(Float32)level
{
    AudioUnitSetParameter(self.delay.audioUnit,
                          kDelayParam_DelayTime,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

// Global, Percent, -100->100, 50
- (void)setDelayFeedback:(Float32)level
{
    AudioUnitSetParameter(self.delay.audioUnit,
                          kDelayParam_Feedback,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

// Global, Hz, 10->(SampleRate/2), 15000
- (void)setDelayCutoff:(Float32)level
{
    AudioUnitSetParameter(self.delay.audioUnit,
                          kDelayParam_LopassCutoff,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

- (void)setCutoffLFOFrequency:(Float32)cutoffLFOFrequency
{
    _cutoffLFOFrequency = cutoffLFOFrequency;
    
    [self.cutoffLFO updateBaseFrequency:cutoffLFOFrequency];
}

- (void)setBaseFrequency:(double)frequency
{
    [self.oscillators enumerateObjectsUsingBlock:^(JFSOscillator *oscillator, NSUInteger idx, BOOL *stop) {
        [oscillator updateBaseFrequency:frequency];
    }];
}

- (void)setLFOAmount:(Float32)lfoAmount
{
    _cuttoffLFOAmount = lfoAmount;
}

- (void)setVolumeForOscillatorAtIndex:(int)oscillatorIdx value:(Float32)value
{
    if ([self.oscillatorChannels count] > oscillatorIdx) {
        AEBlockChannel *channel = self.oscillatorChannels[oscillatorIdx];
        channel.volume = value;
    }
}
- (void)setSemitonesForOscillatorAtIndex:(int)oscillatorIdx value:(int)semitones
{
    [self.oscillators[oscillatorIdx] updateSemitone:semitones];
}

- (void)setFineForOscillatorAtIndex:(int)oscillatorIdx value:(Float32)fine
{
    [self.oscillators[oscillatorIdx] updateFine:fine];
}

#pragma setup methods

- (AEBlockChannel *)oscillatorChannelWithOscillator:(JFSOscillator *)oscillator
{
    __weak JFSSynthController *weakSelf = self;
    
    AEBlockChannel *oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        for (int i = 0; i < frames; i++) {
            
            Float32 filterModAmount = 0.0f;
            
            if (weakSelf.cutoffLFO.baseFrequency > 0) {
                
                filterModAmount = ((Float32)[weakSelf.cutoffLFO updateOscillator] / INT16_MAX) * ([weakSelf minimumCutoff] + [weakSelf maximumCutoff]) + [weakSelf minimumCutoff];
                
                filterModAmount *= weakSelf.cuttoffLFOAmount;
            }
            
            AudioUnitSetParameter(weakSelf.lpFilter.audioUnit,
                                  kLowPassParam_CutoffFrequency,
                                  kAudioUnitScope_Global,
                                  0,
                                  [weakSelf.filterEnvelopeGenerator updateState] + filterModAmount,
                                  0);
            
            SInt16 sample = [oscillator updateOscillator] * [weakSelf.ampEnvelopeGenerator updateState];
            
            ((SInt16 *)audio->mBuffers[0].mData)[i] = sample;
            ((SInt16 *)audio->mBuffers[1].mData)[i] = sample;
        }
    }];
    
    oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
    
    return oscillatorChannel;
}

- (void)playFrequency:(double)frequency
{
    [self setBaseFrequency:frequency];
    
    [self.ampEnvelopeGenerator start];
    [self.filterEnvelopeGenerator start];
}

- (void)stopPlaying
{
    [self.ampEnvelopeGenerator stop];
    [self.filterEnvelopeGenerator stop];
}

#pragma mark - min/max values

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

- (Float32)minimumDelayDryWet
{
    return 0;
}

- (Float32)maximumDelayDryWet
{
    return 100;
}

- (Float32)minimumDelayFeedback
{
    return -100;
}

- (Float32)maximumDelayFeedback
{
    return 100;
}

- (Float32)minimumDelayTime
{
    return 0;
}

- (Float32)maximumDelayTime
{
    return 2;
}

- (Float32)minimumDelayCutoff
{
    return 10;
}

- (Float32)maximumDelayCutoff
{
    return SAMPLE_RATE/2;
}

@end
