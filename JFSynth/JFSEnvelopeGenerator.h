//
//  JFSEnvelopeGenerator.h
//  JFSynth
//
//  Created by John Forester on 11/14/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFSEnvelopeState) {
    JFSEnvelopeStateNone,
    JFSEnvelopeStateAttack,
    JFSEnvelopeStateSustain,
    JFSEnvelopeStateDecay,
    JFSEnvelopeStateRelease,
};

@interface JFSEnvelopeGenerator : NSObject

@property (nonatomic, assign) JFSEnvelopeState envelopeState;

@property (nonatomic, assign) Float32 attackTime;
@property (nonatomic, assign) Float32 decayTime;
@property (nonatomic, assign) Float32 sustainLevel;
@property (nonatomic, assign) Float32 releaseTime;

@property (nonatomic, assign) Float32 level;
@property (nonatomic, assign) Float32 peak;

@property (nonatomic, assign) Float32 sampleRate;

- (Float32)updateState;
- (instancetype)initWithSampleRate:(Float32)sampleRate;

@end
