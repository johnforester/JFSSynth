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
    self.semitoneSlider.value = [synthController.oscillators[0] semitones];
    self.fineSlider.value = [synthController.oscillators[0] fine];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [self.oscillator setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [[JFSSynthController sharedController] setValue:knob.value forParameter:knob.tag];
}

@end
