//
//  JFSDistortionViewController.m
//  JFSynth
//
//  Created by jforester on 1/15/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSDistortionViewController.h"
#import "JFSKnob.h"
#import "JFSSynthController.h"
#import "JFSDistortion.h"

@interface JFSDistortionViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *distortionMixKnob;
@property (weak, nonatomic) IBOutlet JFSKnob *distortionGainKnob;

@end

@implementation JFSDistortionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    
    self.distortionGainKnob.minimumValue = [[self.distortion minimumValueForParameter:JFSDistortionParamGain] floatValue];
    self.distortionGainKnob.maximumValue = [[self.distortion maximumValueForParameter:JFSDistortionParamGain] floatValue];
    self.distortionGainKnob.value = [self.distortion valueForParameter:JFSDistortionParamGain];
    
    self.distortionMixKnob.minimumValue = [[self.distortion minimumValueForParameter:JFSDistortionParamMix] floatValue];
    self.distortionMixKnob.maximumValue = [[self.distortion maximumValueForParameter:JFSDistortionParamMix] floatValue];
    self.distortionMixKnob.value = [self.distortion valueForParameter:JFSDistortionParamMix];
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDistortion:sender.isOn];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [self.distortion setValue:knob.value forParameter:knob.tag];
}


@end
