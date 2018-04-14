//
//  JFSDistortion.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSDistortion.h"
#import <TheAmazingAudioEngine/AEAudioUnitFilter.h>

@interface JFSDistortion ()

@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;

@end

@implementation JFSDistortion

- (instancetype)initWithAudioController:(AEAudioController *)audioController
{
    if (self = [super init]) {
        _minimumValues = @{
                           @(JFSDistortionParamGain) : @(-80),
                           @(JFSDistortionParamMix) : @(0),
                           };
        
        _maximumValues = @{
                           @(JFSDistortionParamGain) : @(20),
                           @(JFSDistortionParamMix) : @(100)
                           };
        
        AudioComponentDescription distortionComponent = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                        kAudioUnitType_Effect,
                                                                                        kAudioUnitSubType_Distortion);

        self.auFilter = [[AEAudioUnitFilter alloc] initWithComponentDescription:distortionComponent];
        [self.auFilter setupWithAudioController:audioController];
        [audioController addFilter:self.auFilter];
    }
    
    return self;
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

- (Float32)valueForParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
        case JFSDistortionParamGain:
            return [self distortionGain];
        case JFSDistortionParamMix:
            return [self distortionMix];
        default:
            break;
    }
    
    return 0;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
        case JFSDistortionParamGain:
            [self setDistortionGain:value];
            break;
        case JFSDistortionParamMix:
            [self setDistortionMix:value];
            break;
        default:
            break;
    }
}

- (Float32)distortionMix
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDistortionParam_FinalMix,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (void)setDistortionMix:(Float32)value
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDistortionParam_FinalMix,
                          kAudioUnitScope_Global,
                          0,
                          value,
                          0);
}

- (Float32)distortionGain
{
    Float32 value;
    
    AudioUnitGetParameter(self.auFilter.audioUnit,
                          kDistortionParam_SoftClipGain,
                          kAudioUnitScope_Global,
                          0,
                          &value);
    
    return value;
}

- (void)setDistortionGain:(Float32)value
{
    AudioUnitSetParameter(self.auFilter.audioUnit,
                          kDistortionParam_SoftClipGain,
                          kAudioUnitScope_Global,
                          0,
                          value,
                          0);
}

@end
