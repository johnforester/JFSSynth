//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthManager.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *attackSlider;
@property (weak, nonatomic) IBOutlet UISlider *decaySlider;
@property (weak, nonatomic) IBOutlet UISlider *sustainSlider;
@property (weak, nonatomic) IBOutlet UISlider *releaseSlider;
@property (weak, nonatomic) IBOutlet UISlider *peakSlider;

@property (weak, nonatomic) IBOutlet UISlider *cutoffSlider;
@property (weak, nonatomic) IBOutlet UISlider *resonanceSlider;

@end

@implementation JFSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JFSSynthManager *audioManager = [JFSSynthManager sharedManager];
    
    //TODO move min and max to audio manager
    
    self.attackSlider.minimumValue = 0.0001;
    self.attackSlider.maximumValue = 2;
    self.attackSlider.value = audioManager.attackTime;
    
    self.peakSlider.minimumValue = 0.0;
    self.peakSlider.maximumValue = 127.0;
    self.peakSlider.value = audioManager.attackPeak;
    
    self.decaySlider.minimumValue = 0;
    self.decaySlider.maximumValue = 2;
    self.decaySlider.value = audioManager.decayTime;
    
    self.sustainSlider.minimumValue = 0;
    self.sustainSlider.maximumValue = audioManager.maxMidiVelocity;
    self.sustainSlider.value = audioManager.maxMidiVelocity;
    
    self.releaseSlider.minimumValue = 0;
    self.releaseSlider.maximumValue = 2;
    self.releaseSlider.value = audioManager.releaseTime;
    
    self.cutoffSlider.minimumValue = 0;
    self.cutoffSlider.maximumValue = 127;
    self.cutoffSlider.value = audioManager.cutoffLevel;
    
    self.resonanceSlider.minimumValue = 0;
    self.resonanceSlider.maximumValue = 127;
    self.resonanceSlider.value = audioManager.resonanceLevel;
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

- (IBAction)peakSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].attackPeak = slider.value;
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

- (IBAction)cutoffSliderChanged:(UISlider *)sender
{
    
}

- (IBAction)resonanceSliderChanged:(id)sender
{
    
}

@end
