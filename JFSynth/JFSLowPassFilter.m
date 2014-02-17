//
//  JFSLowPassFilter.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSLowPassFilter.h"
#import "TheAmazingAudioEngine.h"

#define MINIMUM_CUTOFF 1000.0f
#define MAXIMUM_CUTOFF SAMPLE_RATE/2
#define SAMPLE_RATE 44100.0

@interface JFSLowPassFilter ()

@property (nonatomic, strong) AEAudioUnitFilter *auFilter;
@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;

@end

@implementation JFSLowPassFilter

- (instancetype)initWithAudioController:(AEAudioController *)audioController
{
    if (self = [super init]) {
        _minimumValues = @{
                           @(JFSLowPassFilterParamCutoff) : @(MINIMUM_CUTOFF),
                           @(JFSLowPassFilterParamResonance) : @(-20.0f)
                           };
        
        _maximumValues = @{
                           @(JFSLowPassFilterParamCutoff) : @(SAMPLE_RATE/2.0f),
                           @(JFSLowPassFilterParamResonance) : @(40.0f)
                           };
        
        AudioComponentDescription lpFilterComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                      kAudioUnitType_Effect,
                                                                                      kAudioUnitSubType_LowPassFilter);
        
        NSError *error = nil;
        
        self.auFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:lpFilterComponent
                                                                audioController:audioController
                                                                          error:&error];
        
        
        if (error) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        } else {
            [self setCutoffLevel:10000];
            [self setCutoffKnobLevel:10000];
            [audioController addFilter:self.auFilter];
        }
    }
    
    return self;
}

- (NSNumber *)minimumValueForParameter:(JFSSynthParameter)parameter
{
    return self.minimumValues[@(parameter)];
}

- (NSNumber *)maximumValueForParameter:(JFSSynthParameter)parameter
{
    return self.maximumValues[@(parameter)];
}

// Global, dB, -20->40, 0
- (void)setResonanceLevel:(Float32)resonanceLevel
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kLowPassParam_Resonance,
                          kAudioUnitScope_Global,
                          0,
                          resonanceLevel,
                          0);
}

- (Float32)cutoffLevel
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

// Global, Hz, 10->(SampleRate/2), 6900
- (void)setCutoffLevel:(Float32)cutoffLevel
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kLowPassParam_CutoffFrequency,
                          kAudioUnitScope_Global,
                          0,
                          cutoffLevel,
                          0);
    
#warning connect to envelope
    //    self.filterEnvelopeGenerator.peak = (cutoffLevel - 10) / ([[self maximumValueForParameter:JFSSynthParamCutoff] floatValue] - 10);
}

- (Float32)resonanceLevel
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kLowPassParam_Resonance,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParameter)parameter
{
    switch (parameter) {
            
        case JFSLowPassFilterParamCutoff:
            [self setCutoffLevel:value];
            [self setCutoffKnobLevel:value];
            break;
        case JFSLowPassFilterParamResonance:
            [self setResonanceLevel:value];
            break;
    }
}

- (Float32)valueForParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
        case JFSLowPassFilterParamCutoff:
            return [self cutoffLevel];
        case JFSLowPassFilterParamResonance:
            return [self resonanceLevel];
        default:
            break;
    }
    
    return 0;
}
@end
