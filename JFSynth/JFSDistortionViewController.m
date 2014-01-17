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

@interface JFSDistortionViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *distortionMixKnob;
@property (weak, nonatomic) IBOutlet JFSKnob *distortionGainKnob;

@end

@implementation JFSDistortionViewController

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

    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    
    JFSSynthController *synthController = [JFSSynthController sharedController];

    self.distortionGainKnob.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDistortionGain] floatValue];
    self.distortionGainKnob.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDistortionGain] floatValue];
    self.distortionGainKnob.value = [synthController valueForParameter:JFSSynthParamDistortionGain];
    
    self.distortionMixKnob.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDistortionMix] floatValue];
    self.distortionMixKnob.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDistortionMix] floatValue];
    self.distortionMixKnob.value = [synthController valueForParameter:JFSSynthParamDistortionMix];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDistortion:sender.isOn];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [[JFSSynthController sharedController] setValue:knob.value forParameter:knob.tag];
}


@end
