//
//  JFSFilterViewController.m
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import "JFSFilterViewController.h"
#import "JFSKnob.h"
#import "JFSLowPassFilter.h"

@interface JFSFilterViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *cutoffSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *resonanceSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *cutoffLFOSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *lfoAmountSlider;

@property (nonatomic, strong) JFSLowPassFilter *filter;

@end

@implementation JFSFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cutoffSlider.minimumValue = [[self.filter minimumValueForParameter:JFSLowPassFilterParamCutoff] floatValue];
    self.cutoffSlider.maximumValue = [[self.filter maximumValueForParameter:JFSLowPassFilterParamCutoff] floatValue];
    self.cutoffSlider.value = [self.filter valueForParameter:JFSLowPassFilterParamCutoff];
    
    self.resonanceSlider.minimumValue = [[self.filter minimumValueForParameter:JFSLowPassFilterParamResonance] floatValue];
    self.resonanceSlider.maximumValue = [[self.filter maximumValueForParameter:JFSLowPassFilterParamResonance] floatValue];
    self.resonanceSlider.value = [self.filter valueForParameter:JFSLowPassFilterParamResonance];
    
//    self.cutoffLFOSlider.minimumValue = [[self.filter minimumValueForParameter:JFSSynthParamCutoffLFORate] floatValue];
//    self.cutoffLFOSlider.maximumValue = [[self.filter maximumValueForParameter:JFSSynthParamCutoffLFORate] floatValue];
//    self.cutoffLFOSlider.value = [self.filter valueForParameter:JFSSynthParamCutoffLFORate];
//    
//    self.lfoAmountSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamCutoffLFOAmount] floatValue];
//    self.lfoAmountSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamCutoffLFOAmount] floatValue];
//    self.lfoAmountSlider.value = [synthController valueForParameter:JFSSynthParamCutoffLFOAmount];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [self.filter setValue:knob.value forParameter:knob.tag];
}

@end
