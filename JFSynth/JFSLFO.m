//
//  JFSLFO.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSLFO.h"

@interface JFSLFO ()

@property (nonatomic, strong) NSDictionary *minimumValues;
@property (nonatomic, strong) NSDictionary *maximumValues;


@end

@implementation JFSLFO

- (NSDictionary *)minimumValues
{
    if (_minimumValues == nil) {
        _minimumValues = @{
                           @(JFSLFOParameterRate) : @(0),
                           @(JFSLFOParameterAmount) : @(0),
                           };
    }
    
    return _minimumValues;
}

- (NSDictionary *)maximumValues
{
    if (_maximumValues == nil) {
        _maximumValues = @{
                           @(JFSLFOParameterRate) : @(10.0f),
                           @(JFSLFOParameterAmount) : @(1),
                           };
    }
    
    return _maximumValues;
}

- (Float32)valueForParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
        case JFSLFOParameterAmount:
            return self.LFOAmount;
        case JFSLFOParameterRate:
            return [self LFOFrequency];
        default:
            break;
    }
    
    return 0;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParameter)parameter
{
    switch (parameter)
    {
            
        case JFSLFOParameterAmount:
            [self setLFOAmount:value];
            break;
        case JFSLFOParameterRate:
            [self setLFOFrequency:value];
            break;
        default:
            break;
    }
}

#pragma mark - accessors

- (void)setLFOFrequency:(Float32)LFOFrequency
{
    _LFOFrequency = LFOFrequency;
    
    [self updateBaseFrequency:LFOFrequency];
}

- (void)setLFOAmount:(Float32)lfoAmount
{
    _LFOAmount = lfoAmount;
}

@end
