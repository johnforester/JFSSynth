//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSAudioManager.h"

@interface JFSViewController ()

@end

@implementation JFSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)playA:(id)sender
{
    [[JFSAudioManager sharedManager] playFrequency:440.0];
}

- (IBAction)playD:(id)sender
{
    [[JFSAudioManager sharedManager] playFrequency:587.33];
}

- (IBAction)stop:(id)sender
{
    [[JFSAudioManager sharedManager] stopPlaying];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSAudioManager sharedManager] setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)attackSliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateAttackAmount:slider.value];
}

- (IBAction)decaySliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateDecayAmount:slider.value];
}

- (IBAction)sustainSliderChanged:(UISlider *)slider
{
   // [[JFSAudioManager sharedManager] updateSustainAmount:slider.value];
}

- (IBAction)releaseSliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateReleaseAmount:slider.value];
}

@end
