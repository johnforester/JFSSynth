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
@property (nonatomic, strong) AEAudioUnitFilter *distortion;

@property (nonatomic, assign) Float32 cuttoffLFOAmount;
@property (nonatomic, strong) NSArray *oscillators;

@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;

@end

@implementation JFSSynthController

#define SAMPLE_RATE 44100.0
#define MINIMUM_CUTOFF 1000.0f
#define MAXIMUM_CUTOFF SAMPLE_RATE/2
#define OSC_MIX 0.5 //TODO add control for this

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
        
        _minimumValues = @{@(JFSSynthParamCutoff) : @(MINIMUM_CUTOFF),
                           @(JFSSynthParamResonance) : @(-20.0f),
                           
                           @(JFSSynthParamCutoffLFORate) : @(0),
                           @(JFSSynthParamCutoffLFOAmount) : @(0),
                           
                           @(JFSSynthParamDelayDryWet) : @(0),
                           @(JFSSynthParamDelayFeedback) : @(-100),
                           @(JFSSynthParamDelayTime) : @(0),
                           @(JFSSynthParamDelayCutoff) : @(10),
                           
                           @(JFSSynthParamOscillator1Semitones) : @(-24),
                           @(JFSSynthParamOscillator1Fine) : @(0),
                           @(JFSSynthParamOscillator2Semitones) : @(-24),
                           @(JFSSynthParamOscillator2Fine) : @(0),
                           @(JFSSynthControllerOscillator1Volume) : @(0),
                           @(JFSSynthControllerOscillator2Volume) : @(0),
                           
                           @(JFSSynthParamDistortionGain) : @(-80),
                           @(JFSSynthParamDistortionMix) : @(0),
                           };
        
        _maximumValues = @{@(JFSSynthParamCutoff) : @(SAMPLE_RATE/2.0f),
                           @(JFSSynthParamResonance) : @(40.0f),
                           
                           @(JFSSynthParamCutoffLFORate) : @(10.0f),
                           @(JFSSynthParamCutoffLFOAmount) : @(1),
                           
                           @(JFSSynthParamDelayDryWet) : @(100),
                           @(JFSSynthParamDelayFeedback) : @(100),
                           @(JFSSynthParamDelayTime) : @(2),
                           @(JFSSynthParamDelayCutoff) : @(SAMPLE_RATE/2),
                           
                           @(JFSSynthParamOscillator1Semitones) : @(24),
                           @(JFSSynthParamOscillator1Fine) : @(1),
                           @(JFSSynthParamOscillator2Semitones) : @(24),
                           @(JFSSynthParamOscillator2Fine) : @(1),
                           @(JFSSynthControllerOscillator1Volume) : @(1),
                           @(JFSSynthControllerOscillator2Volume) : @(1),
                           
                           @(JFSSynthParamDistortionGain) : @(20),
                           @(JFSSynthParamDistortionMix) : @(100)
                           };
        
        _audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
                            inputEnabled:NO];
        
        _ampEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        [_ampEnvelopeGenerator setMidiVelocity:60];
        
        _filterEnvelopeGenerator = [[JFSEnvelopeGenerator alloc] initWithSampleRate:SAMPLE_RATE];
        _filterEnvelopeGenerator.peak = 1.0;
        
        _oscillators = @[[[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE], [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE]];
        
        [_oscillators[0] updateVolume:0.7];
        [_oscillators[1] updateVolume:0.7];
        [_oscillators[1] updateFine:0.05];
        
        _oscillatorChannel = [self oscillatorChannel];
        [_audioController addChannels:@[_oscillatorChannel]];
        
        _cutoffLFO = [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE];
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
            [self setCutoffLevel:10000];
            [self setCutoffKnobLevel:10000];
            [_audioController addFilter:_lpFilter];
        }
        
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
        
        AudioComponentDescription distortionComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                        kAudioUnitType_Effect,
                                                                                        kAudioUnitSubType_Distortion);
        
        _distortion = [[AEAudioUnitFilter alloc] initWithComponentDescription:distortionComponent
                                                              audioController:_audioController
                                                                        error:&error];
        
        
        if (error) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        } else {
            
            [_audioController addFilter:_distortion];
        }
        
        error = nil;
        
        if (![_audioController start:&error]) {
            NSLog(@"AudioController start error: %@", [error localizedDescription]);
        }
    }
    
    return self;
}

- (void)toggleDelay:(BOOL)on
{
    if (on) {
        [self.audioController addFilter:self.delay];
    } else {
        [self.audioController removeFilter:self.delay];
    }
}

- (void)toggleDistortion:(BOOL)on
{
    if (on) {
        [self.audioController addFilter:self.distortion];
    } else {
        [self.audioController removeFilter:self.distortion];
    }
}

#pragma accessor methods

- (Float32)valueForParameter:(JFSSynthParam)parameter
{
    switch (parameter) {
        case JFSSynthParamCutoff:
            return [self cutoffLevel];
        case JFSSynthParamCutoffLFOAmount:
            return [self cuttoffLFOAmount];
        case JFSSynthParamCutoffLFORate:
            return [self cutoffLFOFrequency];
        case JFSSynthParamDelayCutoff:
            return [self delayCutoff];
        case JFSSynthParamDelayDryWet:
            return [self delayDryWet];
        case JFSSynthParamDelayFeedback:
            return [self delayFeedback];
        case JFSSynthParamDelayTime:
            return [self delayTime];
        case JFSSynthParamDistortionGain:
            return [self distortionGain];
        case JFSSynthParamDistortionMix:
            return [self distortionMix];
        case JFSSynthParamOscillator1Fine:
            return [self.oscillators[0] fine];
        case JFSSynthParamOscillator2Fine:
            return [self.oscillators[1] fine];
        case JFSSynthParamOscillator1Semitones:
            return [self.oscillators[0] semitones];
        case JFSSynthParamOscillator2Semitones:
            return [self.oscillators[1] semitones];
        case JFSSynthParamResonance:
            return [self resonanceLevel];
        case JFSSynthParamFrequency:
            //TODO
            break;
        case JFSSynthParamVelocity:
            return self.velocityPeak;
            break;
        case JFSSynthControllerOscillator1Volume:
            return [self.oscillators[0] volume];
        case JFSSynthControllerOscillator2Volume:
            return [self.oscillators[1] volume];
        default:
            break;
    }
    
    return 0;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParam)parameter
{
    switch (parameter) {
        case JFSSynthParamCutoff:
            [self setCutoffLevel:value];
            [self setCutoffKnobLevel:value];
            break;
        case JFSSynthParamCutoffLFOAmount:
            [self setCutoffLFOAmount:value];
            break;
        case JFSSynthParamCutoffLFORate:
            [self setCutoffLFOFrequency:value];
            break;
        case JFSSynthParamDelayCutoff:
            [self setDelayCutoff:value];
            break;
        case JFSSynthParamDelayDryWet:
            [self setDelayWetDry:value];
            break;
        case JFSSynthParamDelayFeedback:
            [self setDelayFeedback:value];
            break;
        case JFSSynthParamDelayTime:
            [self setDelayTime:value];
            break;
        case JFSSynthParamDistortionGain:
            [self setDistortionGain:value];
            break;
        case JFSSynthParamDistortionMix:
            [self setDistortionMix:value];
            break;
        case JFSSynthParamOscillator1Fine:
            [self setFineForOscillatorAtIndex:0 value:value];
            break;
        case JFSSynthParamOscillator2Fine:
            [self setFineForOscillatorAtIndex:1 value:value];
            break;
        case JFSSynthParamOscillator1Semitones:
            [self setSemitonesForOscillatorAtIndex:0 value:value];
            break;
        case JFSSynthParamOscillator2Semitones:
            [self setSemitonesForOscillatorAtIndex:1 value:value];
            break;
        case JFSSynthParamResonance:
            [self setResonanceLevel:value];
            break;
        case JFSSynthParamFrequency:
            //TODO
            break;
        case JFSSynthParamVelocity:
            [self setVelocityPeak:value];
            break;
        case JFSSynthControllerOscillator1Volume:
            [self setVolumeForOscillatorAtIndex:0 value:value];
            break;
        case JFSSynthControllerOscillator2Volume:
            [self setVolumeForOscillatorAtIndex:1 value:value];
            break;
        default:
            break;
    }
}

// Global, Hz, 10->(SampleRate/2), 6900
- (void)setCutoffLevel:(Float32)cutoffLevel
{
    AudioUnitSetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          cutoffLevel,
                          0);
    
    self.filterEnvelopeGenerator.peak = (cutoffLevel - 10) / ([[self maximumValueForParameter:JFSSynthParamCutoff] floatValue] - 10);
}

// Global, dB, -20->40, 0
- (void)setResonanceLevel:(Float32)resonanceLevel
{
    AudioUnitSetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_Resonance,
                          kAudioUnitScope_Global,
                          0,
                          resonanceLevel,
                          0);
}

- (Float32)cutoffLevel
{
    Float32 value;
    
    AudioUnitGetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (Float32)resonanceLevel
{
    Float32 value;
    
    AudioUnitGetParameter(self.lpFilter.audioUnit,
                          kLowPassParam_Resonance,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
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

- (Float32)delayDryWet
{
    Float32 value;
    
    AudioUnitGetParameter(self.delay.audioUnit,
                          kDelayParam_WetDryMix,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
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

- (Float32)delayTime
{
    Float32 value;
    
    AudioUnitGetParameter(self.delay.audioUnit,
                          kDelayParam_DelayTime,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
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

- (Float32)delayFeedback
{
    Float32 value;
    
    AudioUnitGetParameter(self.delay.audioUnit,
                          kDelayParam_Feedback,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
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

- (Float32)delayCutoff
{
    Float32 value;
    
    AudioUnitGetParameter(self.delay.audioUnit,
                          kDelayParam_LopassCutoff,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (Float32)distortionMix
{
    Float32 value;
    
    AudioUnitGetParameter(self.distortion.audioUnit,
                          kDistortionParam_FinalMix,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (void)setDistortionMix:(Float32)value
{
    AudioUnitSetParameter(self.distortion.audioUnit,
                          kDistortionParam_FinalMix,
                          kAudioUnitScope_Global,
                          0,
                          value,
                          0);
}

- (Float32)distortionGain
{
    Float32 value;
    
    AudioUnitGetParameter(self.distortion.audioUnit,
                          kDistortionParam_SoftClipGain,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (void)setDistortionGain:(Float32)value
{
    AudioUnitSetParameter(self.distortion.audioUnit,
                          kDistortionParam_SoftClipGain,
                          kAudioUnitScope_Global,
                          0,
                          value,
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

- (void)setCutoffLFOAmount:(Float32)lfoAmount
{
    _cuttoffLFOAmount = lfoAmount;
}

- (void)setVolumeForOscillatorAtIndex:(int)oscillatorIdx value:(Float32)value
{
    if ([self.oscillators count] > oscillatorIdx) {
        [self.oscillators[oscillatorIdx] updateVolume:value];
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

- (AEBlockChannel *)oscillatorChannel
{
    __weak JFSSynthController *weakSelf = self;
    
    AEBlockChannel *oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        for (int i = 0; i < frames; i++) {
            
            Float32 filterModAmount = 0.0f;
            
            if (weakSelf.cutoffLFO.baseFrequency > 0.0f) {
                
                filterModAmount = ((Float32)[weakSelf.cutoffLFO updateOscillator] / INT16_MAX) * (MINIMUM_CUTOFF + MAXIMUM_CUTOFF) + MINIMUM_CUTOFF;
                
                filterModAmount *= weakSelf.cuttoffLFOAmount;
            }
            
            Float32 cutoffLevel = ([weakSelf.filterEnvelopeGenerator updateState] * weakSelf.cutoffKnobLevel) + filterModAmount;
            
            printf("cutofflevel %f\n", cutoffLevel);
            
            cutoffLevel = MAX(MINIMUM_CUTOFF, cutoffLevel);
            cutoffLevel = MIN(MAXIMUM_CUTOFF, cutoffLevel);
            
            AudioUnitSetParameter(weakSelf.lpFilter.audioUnit,
                                  kLowPassParam_CutoffFrequency,
                                  kAudioUnitScope_Global,
                                  0,
                                  cutoffLevel,
                                  0);
            
            SInt16 oscSampleSum = (([weakSelf.oscillators[0] volume]) * [weakSelf.oscillators[0] updateOscillator]) + ([weakSelf.oscillators[1] volume] * [weakSelf.oscillators[1] updateOscillator]);
            
            SInt16 sample = oscSampleSum * [weakSelf.ampEnvelopeGenerator updateState];
            
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

- (void)playMidiNote:(int)midiNote
{
    double frequency = pow(2, (double)(midiNote - 69) / 12) * 440;
    [self playFrequency:frequency];
}

- (void)stopPlaying
{
    [self.ampEnvelopeGenerator stop];
    [self.filterEnvelopeGenerator stop];
}

#pragma mark - min/max values

- (Float32)minimumEnvelopeTime
{
    return 0.0001f;
}

- (Float32)maximumEnvelopeTime
{
    return 8.0f;
}

- (Float32)minimumVelocity
{
    return 0.001;
}

- (Float32)maximumVelocity
{
    return 127.0;
}

- (NSNumber *)minimumValueForParameter:(JFSSynthParam)parameter
{
    return self.minimumValues[@(parameter)];
}

- (NSNumber *)maximumValueForParameter:(JFSSynthParam)parameter
{
    return self.maximumValues[@(parameter)];
}

@end
