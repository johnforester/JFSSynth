//
//  JFSDelayViewController.m
//  JFSynth
//
//  Created by jforester on 1/15/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSDelayViewController.h"
#import "JFSKnob.h"
#import "JFSSynthController.h"
#import "JFSDelay.h"

@interface JFSDelayViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *delayDryWetSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayFeedbackSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayTimeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayCutoffSlider;

@end

@implementation JFSDelayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    
    self.delayDryWetSlider.minimumValue = [[self.delay minimumValueForParameter:JFSDelayParamDryWet] floatValue];
    self.delayDryWetSlider.maximumValue = [[self.delay maximumValueForParameter:JFSDelayParamDryWet] floatValue];
    self.delayDryWetSlider.value = [self.delay valueForParameter:JFSDelayParamDryWet];
    
    self.delayFeedbackSlider.minimumValue = [[self.delay minimumValueForParameter:JFSDelayParamFeedback] floatValue];
    self.delayFeedbackSlider.maximumValue = [[self.delay maximumValueForParameter:JFSDelayParamFeedback] floatValue];
    self.delayFeedbackSlider.value = [self.delay valueForParameter:JFSDelayParamFeedback];
    
    self.delayCutoffSlider.minimumValue = [[self.delay minimumValueForParameter:JFSDelayParamCutoff] floatValue];
    self.delayCutoffSlider.maximumValue = [[self.delay maximumValueForParameter:JFSDelayParamCutoff] floatValue];
    self.delayCutoffSlider.value = [self.delay valueForParameter:JFSDelayParamCutoff];
    
    self.delayTimeSlider.minimumValue = [[self.delay minimumValueForParameter:JFSDelayParamTime] floatValue];
    self.delayTimeSlider.maximumValue = [[self.delay maximumValueForParameter:JFSDelayParamTime] floatValue];
    self.delayTimeSlider.value = [self.delay valueForParameter:JFSDelayParamTime];
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDelay:sender.isOn];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [self.delay setValue:knob.value forParameter:knob.tag];
}

@end
