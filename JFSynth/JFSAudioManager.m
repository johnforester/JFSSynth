//
//  JFSAudioManager.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSAudioManager.h"
#import "TheAmazingAudioEngine.h"

@interface JFSAudioManager ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEBlockChannel *oscillatorChannel;

@property (nonatomic, assign) double waveLengthInSamples;

@end

@implementation JFSAudioManager

#define SAMPLE_RATE 44100.0

+ (JFSAudioManager *) sharedManager
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
        _audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:NO];
        
        __weak JFSAudioManager *weakSelf = self;
        
        _oscillatorChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            for (int i = 0; i < frames; i++) {
                int16_t sample;
                
                switch (weakSelf.waveType)
                {
                    case JFSSquareWave:
                        if (i < weakSelf.waveLengthInSamples) {
                            sample = INT16_MAX;
                        } else {
                            sample = INT16_MIN;
                        }
                        
                        break;
                    case JFSSineWave:
                        sample = (SInt16)SHRT_MAX * sin(2 * M_PI * (i / weakSelf.waveLengthInSamples));
                        break;
                    default:
                        break;
                }
                
                ((SInt16*)audio->mBuffers[0].mData)[i] = sample;
                ((SInt16*)audio->mBuffers[1].mData)[i] = sample;
            }
        }];
    }
    
    _oscillatorChannel.audioDescription = [AEAudioController nonInterleaved16BitStereoAudioDescription];
    
    [_audioController addChannels:@[_oscillatorChannel]];
    
    NSError *error = nil;
    
    if (![_audioController start:&error]) {
        NSLog(@"AudioController start error: %@", [error localizedDescription]);
    }
    
    return self;
}

- (void)playFrequency:(double)frequency
{
    self.waveLengthInSamples = SAMPLE_RATE / frequency;
}


@end
