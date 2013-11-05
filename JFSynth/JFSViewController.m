//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthManager.h"
#import "JFSEnvelopeView.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *attackSlider;
@property (weak, nonatomic) IBOutlet UISlider *decaySlider;
@property (weak, nonatomic) IBOutlet UISlider *sustainSlider;
@property (weak, nonatomic) IBOutlet UISlider *releaseSlider;
@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet UISlider *cutoffSlider;
@property (weak, nonatomic) IBOutlet UISlider *resonanceSlider;

@property (strong, nonatomic) JFSEnvelopeView *envelopeView;

@end

@implementation JFSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.envelopeView) {
        self.envelopeView = [[JFSEnvelopeView alloc] initWithFrame:CGRectMake(60, 400, 300, 200)];
        [self.view addSubview:self.envelopeView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    JFSSynthManager *audioManager = [JFSSynthManager sharedManager];
    
    //TODO move min and max to audio manager
    
    self.attackSlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.attackSlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.attackSlider.value = audioManager.attackTime;
    
    self.velocityPeakSlider.minimumValue = 0.001;
    self.velocityPeakSlider.maximumValue = 127.0;
    self.velocityPeakSlider.value = audioManager.maxMidiVelocity;
    
    self.decaySlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.decaySlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.decaySlider.value = audioManager.decayTime;
    
    self.sustainSlider.minimumValue = 0;
    self.sustainSlider.maximumValue = 127;
    self.sustainSlider.value = audioManager.maxMidiVelocity;
    
    self.releaseSlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.releaseSlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.releaseSlider.value = audioManager.releaseTime;
    
    self.cutoffSlider.minimumValue = [audioManager minimumCutoff];
    self.cutoffSlider.maximumValue = [audioManager maximumCutoff];
    self.cutoffSlider.value = audioManager.cutoffLevel;
    
    self.resonanceSlider.minimumValue = [audioManager minimumResonance];
    self.resonanceSlider.maximumValue = [audioManager maximumResonance];
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
    [JFSSynthManager sharedManager].maxMidiVelocity = slider.value;
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

- (IBAction)cutoffSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].cutoffLevel = slider.value;
}

- (IBAction)resonanceSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].resonanceLevel = slider.value;
}

@end
