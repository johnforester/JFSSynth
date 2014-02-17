//
//  JFSOscillatorViewController.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSOscillatorViewController.h"
#import "JFSOscillator.h"
#import "JFSKnob.h"
#import "JFSSynthController.h"

@interface JFSOscillatorViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *volumeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *semitoneSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *fineSlider;

@end

@implementation JFSOscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    
    JFSSynthController *synthController = [JFSSynthController sharedController];
    
    self.semitoneSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator1Semitones] floatValue];
    self.semitoneSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator1Semitones] floatValue];
    
    self.fineSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator1Fine] floatValue];
    self.fineSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator1Fine] floatValue];
    
    self.volumeSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthControllerOscillator1Volume] floatValue];
    self.volumeSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthControllerOscillator1Volume] floatValue];
    
    self.semitoneSlider.displayType = JFSKnobDisplayTypeInteger;
    self.semitoneSlider.value = [self.oscillator semitones];
    self.fineSlider.value = [self.oscillator fine];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [self.oscillator setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    if (knob == self.volumeSlider) {
        [self.oscillator updateVolume:knob.value];
    } else if (knob == self.semitoneSlider) {
        [self.oscillator updateSemitone:knob.value];
    } else if (knob == self.fineSlider) {
        [self.oscillator updateFine:knob.value];
    }
}

@end
