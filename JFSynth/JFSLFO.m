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

@end
