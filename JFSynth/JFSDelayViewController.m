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

@interface JFSDelayViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *delayDryWetSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayFeedbackSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayTimeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayCutoffSlider;

@end

@implementation JFSDelayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    JFSSynthController *synthController = [JFSSynthController sharedController];
    
    self.delayDryWetSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDelayDryWet] floatValue];
    self.delayDryWetSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDelayDryWet] floatValue];
    self.delayDryWetSlider.value = [synthController valueForParameter:JFSSynthParamDelayDryWet];
    
    self.delayFeedbackSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDelayFeedback] floatValue];
    self.delayFeedbackSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDelayFeedback] floatValue];
    self.delayFeedbackSlider.value = [synthController valueForParameter:JFSSynthParamDelayFeedback];
    
    self.delayCutoffSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDelayCutoff] floatValue];
    self.delayCutoffSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDelayCutoff] floatValue];
    self.delayCutoffSlider.value = [synthController valueForParameter:JFSSynthParamDelayCutoff];
    
    self.delayTimeSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDelayTime] floatValue];
    self.delayTimeSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDelayTime] floatValue];
    self.delayTimeSlider.value = [synthController valueForParameter:JFSSynthParamDelayTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDelay:sender.isOn];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [[JFSSynthController sharedController] setValue:knob.value forParameter:knob.tag];
}

@end
