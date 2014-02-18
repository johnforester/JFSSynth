//
//  JFSDelay.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSDelay.h"
#import "TheAmazingAudioEngine.h"

#define SAMPLE_RATE 44100.0

@interface JFSDelay ()

@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;

@end

@implementation JFSDelay

- (instancetype)initWithAudioController:(AEAudioController *)audioController
{
    if (self = [super init]) {
        _minimumValues = @{
                           @(JFSDelayParamDryWet) : @(0),
                           @(JFSDelayParamFeedback) : @(-100),
                           @(JFSDelayParamTime) : @(0),
                           @(JFSDelayParamCutoff) : @(10),
                           };
        
        _maximumValues = @{
                           @(JFSDelayParamDryWet) : @(100),
                           @(JFSDelayParamFeedback) : @(100),
                           @(JFSDelayParamTime) : @(2),
                           @(JFSDelayParamCutoff) : @(SAMPLE_RATE/2),
                           };
        
        AudioComponentDescription delayComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                   kAudioUnitType_Effect,
                                                                                   kAudioUnitSubType_Delay);
        
        NSError *error = nil;
        
        self.auFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:delayComponent
                                                                audioController:audioController
                                                                          error:&error];
        
        if (error) {
            NSLog(@"filter initialization error %@", [error localizedDescription]);
        } else {
            [audioController addFilter:self.auFilter];
        }
    }
    
    return self;
}

- (Float32)valueForParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
        case JFSDelayParamTime:
            return [self delayTime];
        case JFSDelayParamFeedback:
            return [self delayFeedback];
        case JFSDelayParamDryWet:
            return [self delayDryWet];
            
        case JFSDelayParamCutoff:
            return [self delayCutoff];
        default:
            break;
    }
    return 0;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
            
        case JFSDelayParamCutoff:
            [self setDelayCutoff:value];
            break;
        case JFSDelayParamDryWet:
            [self setDelayWetDry:value];
            break;
        case JFSDelayParamFeedback:
            [self setDelayFeedback:value];
            break;
        case JFSDelayParamTime:
            [self setDelayTime:value];
            break;
        default:
            break;
    }
    
}

#pragma mark - accessors

- (NSNumber *)minimumValueForParameter:(JFSSynthParameter)parameter
{
    return self.minimumValues[@(parameter)];
}

- (NSNumber *)maximumValueForParameter:(JFSSynthParameter)parameter
{
    return self.maximumValues[@(parameter)];
}

// Global, EqPow Crossfade, 0->100, 50
- (void)setDelayWetDry:(Float32)level
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDelayParam_WetDryMix,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

- (Float32)delayDryWet
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDelayParam_WetDryMix,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

// Global, Secs, 0->2, 1
- (void)setDelayTime:(Float32)level
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDelayParam_DelayTime,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

- (Float32)delayTime
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDelayParam_DelayTime,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

// Global, Percent, -100->100, 50
- (void)setDelayFeedback:(Float32)level
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDelayParam_Feedback,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

- (Float32)delayFeedback
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDelayParam_Feedback,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

// Global, Hz, 10->(SampleRate/2), 15000
- (void)setDelayCutoff:(Float32)level
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDelayParam_LopassCutoff,
                          kAudioUnitScope_Global,
                          0,
                          level,
                          0);
}

- (Float32)delayCutoff
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDelayParam_LopassCutoff,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

@end
