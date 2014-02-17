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
    
    self.semitoneSlider.minimumValue = [[self.oscillator minimumValueForParameter:JFSOscillatorParamSemitones] floatValue];
    self.semitoneSlider.maximumValue = [[self.oscillator maximumValueForParameter:JFSOscillatorParamSemitones] floatValue];
    
    self.fineSlider.minimumValue = [[self.oscillator minimumValueForParameter:JFSOscillatorParamFine] floatValue];
    self.fineSlider.maximumValue = [[self.oscillator maximumValueForParameter:JFSOscillatorParamFine] floatValue];
    
    self.volumeSlider.minimumValue = [[self.oscillator minimumValueForParameter:JFSOscillatorParamVolume] floatValue];
    self.volumeSlider.maximumValue = [[self.oscillator maximumValueForParameter:JFSOscillatorParamVolume] floatValue];
    
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
