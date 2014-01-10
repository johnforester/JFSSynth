//
//  JFSEnvelopeViewController.m
//  JFSynth
//
//  Created by jforester on 1/10/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSEnvelopeViewController.h"
#import "JFSSynthController.h"
#import "JFSEnvelopeView.h"
#import "JFSEnvelopeGenerator.h"

@interface JFSEnvelopeViewController () <JFSEnvelopeViewDataSource, JFSEnvelopeViewDelegate>

@property (nonatomic, strong) JFSEnvelopeGenerator *envelopeGenerator;
@property (nonatomic, strong) JFSEnvelopeView *envelopeView;

@end

@implementation JFSEnvelopeViewController

- (instancetype)initWithEnvelope:(JFSEnvelopeGenerator *)envelopeGenerator
{
    if (self = [super init]) {
        _envelopeGenerator = envelopeGenerator;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];

    if (self.envelopeView == nil) {
        self.envelopeView = [[JFSEnvelopeView alloc]initWithFrame:self.view.bounds];
        self.envelopeView.delegate = self;
        self.envelopeView.dataSource = self;
        [self.view addSubview:_envelopeView];
    }
}

- (void)refresh
{
    [self.envelopeView updateStageViewWithStage:[JFSSynthController sharedController].ampEnvelopeGenerator.envelopeState - 1];
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return self.envelopeGenerator.attackTime;
}

- (Float32)decayTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return self.envelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeakForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return self.envelopeGenerator.sustainLevel / self.envelopeGenerator.peak;
}

- (Float32)releaseTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return self.envelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return [JFSSynthController sharedController].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopeViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint value:(Float32)value
{
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            self.envelopeGenerator.attackTime = value;
            break;
        case JFSEnvelopeViewPointDecay:
            self.envelopeGenerator.decayTime = value;
            break;
        case JFSEnvelopeViewPointSustain:
            [self.envelopeGenerator updateSustainWithMidiValue:value * 127.];
            break;
        case JFSEnvelopeViewPointRelease:
            self.envelopeGenerator.releaseTime = value;
            break;
        default:
            break;
    }
}

@end
