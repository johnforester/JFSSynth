//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthManager.h"

#define ENABLE_SYNTH 0

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#ifdef ENABLE_SYNTH
    
    JFSSynthManager *audioManager = [JFSSynthManager sharedManager];
    
    //TODO move min and max to audio manager
    
    self.attackSlider.minimumValue = 0.0001;
    self.attackSlider.maximumValue = 2;
    self.attackSlider.value = audioManager.attackTime;
    
    self.decaySlider.minimumValue = 0;
    self.decaySlider.maximumValue = 2;
    self.decaySlider.value = audioManager.decayTime;
    
    self.sustainSlider.minimumValue = 0;
    self.sustainSlider.maximumValue = audioManager.maxMidiVelocity;
    self.sustainSlider.value = audioManager.maxMidiVelocity;
    
    self.releaseSlider.minimumValue = 0;
    self.releaseSlider.maximumValue = 2;
    self.releaseSlider.value = audioManager.releaseTime;
    
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)playA:(id)sender
{
    [[JFSSynthManager sharedManager] playFrequency:440.0];
}

- (IBAction)playD:(id)sender
{
    [[JFSSynthManager sharedManager] playFrequency:587.33];
}

- (IBAction)stop:(id)sender
{
    [[JFSSynthManager sharedManager] stopPlaying];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthManager sharedManager] setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)attackSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].attackTime = slider.value;
}

- (IBAction)decaySliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].decayTime = slider.value;
}

- (IBAction)sustainSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].sustainLevel = slider.value;
}

- (IBAction)releaseSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].releaseTime = slider.value;
}

@end
