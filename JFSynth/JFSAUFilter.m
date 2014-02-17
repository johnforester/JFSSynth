//
//  JFSAUFilter.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSAUFilter.h"
#import "TheAmazingAudioEngine.h"

@implementation JFSAUFilter

- (instancetype)initWithAudioController:(AEAudioController *)audioController
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSNumber *)minimumValueForParameter:(JFSSynthParameter)parameter
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSNumber *)maximumValueForParameter:(JFSSynthParameter)parameter
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (void)setValue:(Float32)value forParameter:(JFSSynthParameter)parameter
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (Float32)valueForParameter:(JFSSynthParameter)parameter
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    
    return 0;
}

@end
