//
//  JFSAUFilter.h
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFSSynthComponent.h"

@class AEAudioUnitFilter, AEAudioController;

@interface JFSAUFilter : NSObject<JFSSynthComponent>

@property (nonatomic, readonly) AEAudioUnitFilter *auFilter;

- (instancetype)initWithAudioController:(AEAudioController *)audioController;

@end
