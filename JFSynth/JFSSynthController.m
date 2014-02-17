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
#import "JFSLowPassFilter.h"
#import "JFSLFO.h"

#define MINIMUM_CUTOFF 1000.0f
#define MAXIMUM_CUTOFF SAMPLE_RATE/2
#define SAMPLE_RATE 44100.0
#define OSC_MIX 0.5 //TODO add control for this

@interface JFSSynthController ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;
@property (nonatomic, strong) JFSLowPassFilter *lpFilter;
@property (nonatomic, strong) AEAudioUnitFilter *delay;
@property (nonatomic, strong) AEAudioUnitFilter *distortion;

@property (nonatomic, assign) Float32 cuttoffLFOAmount;
@property (nonatomic, strong) NSArray *oscillators;

@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;

@end

@implementation JFSSynthController

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
        
        _minimumValues = @{
                           @(JFSSynthParamDelayDryWet) : @(0),
                           @(JFSSynthParamDelayFeedback) : @(-100),
                           @(JFSSynthParamDelayTime) : @(0),
                           @(JFSSynthParamDelayCutoff) : @(10),

                           
                           @(JFSSynthParamDistortionGain) : @(-80),
                           @(JFSSynthParamDistortionMix) : @(0),
                           };
        
        _maximumValues = @{
                           @(JFSSynthParamDelayDryWet) : @(100),
                           @(JFSSynthParamDelayFeedback) : @(100),
                           @(JFSSynthParamDelayTime) : @(2),
                           @(JFSSynthParamDelayCutoff) : @(SAMPLE_RATE/2),
                           
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
        _filterEnvelopeGenerator.attackTime = 1.0;
        _filterEnvelopeGenerator.decayTime = 3.0;
        _filterEnvelopeGenerator.sustainLevel = 0.6;
        _filterEnvelopeGenerator.releaseTime = 3.0;
        
        _oscillators = @[[[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE], [[JFSOscillator alloc] initWithSampleRate:SAMPLE_RATE]];
        
        [_oscillators[0] updateVolume:0.7];
        [_oscillators[1] updateVolume:0.7];
        [_oscillators[1] updateFine:0.09];
        
        _oscillatorChannel = [self oscillatorChannel];
        [_audioController addChannels:@[_oscillatorChannel]];
        
        _cutoffLFO = [[JFSLFO alloc] initWithSampleRate:SAMPLE_RATE];
        [_cutoffLFO updateBaseFrequency:0.0f];
        _cuttoffLFOAmount = 0.0f;
        
        _lpFilter = [[JFSLowPassFilter alloc] initWithAudioController:_audioController];
       

        AudioComponentDescription delayComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                   kAudioUnitType_Effect,
                                                                                   kAudioUnitSubType_Delay);
        
        NSError *error = nil;
        
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

- (Float32)outputLevel
{
    Float32 outputLevel;
    Float32 peakLevel;
    [self.audioController outputAveragePowerLevel:&outputLevel peakHoldLevel:&peakLevel];
    
    return peakLevel;
}

#pragma accessor methods

- (Float32)valueForParameter:(JFSSynthParam)parameter
{
    switch (parameter) {
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
        case JFSSynthParamFrequency:
            //TODO
            break;
        case JFSSynthParamVelocity:
            return self.velocityPeak;
            break;
        default:
            break;
    }
    
    return 0;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParam)parameter
{
    switch (parameter) {
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
        case JFSSynthParamFrequency:
            //TODO
            break;
        case JFSSynthParamVelocity:
            [self setVelocityPeak:value];
            break;
        default:
            break;
    }
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
            
            Float32 cutoffLevel = ([weakSelf.filterEnvelopeGenerator updateState] * weakSelf.lpFilter.cutoffKnobLevel) + filterModAmount;
                        
            cutoffLevel = MAX(MINIMUM_CUTOFF, cutoffLevel);
            cutoffLevel = MIN(MAXIMUM_CUTOFF, cutoffLevel);
            
            AudioUnitSetParameter(weakSelf.lpFilter.auFilter.audioUnit,
                                  kLowPassParam_CutoffFrequency,
                                  kAudioUnitScope_Global,
                                  0,
                                  cutoffLevel,
                                  0);
            
            SInt16 osc1Sample = [weakSelf.oscillators[0] volume] * [weakSelf.oscillators[0] updateOscillator];
            SInt16 osc2Sample = [weakSelf.oscillators[1] volume] * [weakSelf.oscillators[1] updateOscillator];
            
            SInt16 sample = (osc1Sample + osc2Sample) * [weakSelf.ampEnvelopeGenerator updateState];
            
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
