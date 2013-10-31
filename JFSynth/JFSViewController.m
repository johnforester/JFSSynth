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

@property (weak, nonatomic) IBOutlet UISlider *attackSlider;
@property (weak, nonatomic) IBOutlet UISlider *decaySlider;
@property (weak, nonatomic) IBOutlet UISlider *sustainSlider;
@property (weak, nonatomic) IBOutlet UISlider *releaseSlider;

@end

@implementation JFSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JFSAudioManager *audioManager = [JFSAudioManager sharedManager];
    
    //TODO move min and max to audio manager
    
    self.attackSlider.minimumValue = 0.0001;
    self.attackSlider.maximumValue = 2;
    self.attackSlider.value = audioManager.attackTime;
    
    self.decaySlider.minimumValue = 0;
    self.decaySlider.maximumValue = 2;
    self.decaySlider.value = audioManager.decayTime;
    
    self.sustainSlider.minimumValue = 0;
    self.sustainSlider.maximumValue = audioManager.maxAmp;
    self.sustainSlider.value = audioManager.sustainAmount;
    
    self.releaseSlider.minimumValue = 0;
    self.releaseSlider.maximumValue = 2;
    self.releaseSlider.value = audioManager.releaseTime;
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
    [[JFSAudioManager sharedManager] updateAttackTime:slider.value];
}

- (IBAction)decaySliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateDecayTime:slider.value];
}

- (IBAction)sustainSliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateSustainAmount:slider.value];
}

- (IBAction)releaseSliderChanged:(UISlider *)slider
{
    [[JFSAudioManager sharedManager] updateReleaseTime:slider.value];
}

@end
