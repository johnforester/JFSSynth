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
#import "JFSLFO.h"

@interface JFSFilterViewController ()

@property (weak, nonatomic) IBOutlet JFSKnob *cutoffSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *resonanceSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *cutoffLFOSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *lfoAmountSlider;

@end

@implementation JFSFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.borderColor = [UIColor redColor].CGColor;
    self.view.layer.borderWidth = 1.0;

    self.cutoffSlider.minimumValue = [[self.filter minimumValueForParameter:JFSLowPassFilterParamCutoff] floatValue];
    self.cutoffSlider.maximumValue = [[self.filter maximumValueForParameter:JFSLowPassFilterParamCutoff] floatValue];
    self.cutoffSlider.value = [self.filter valueForParameter:JFSLowPassFilterParamCutoff];
    
    self.resonanceSlider.minimumValue = [[self.filter minimumValueForParameter:JFSLowPassFilterParamResonance] floatValue];
    self.resonanceSlider.maximumValue = [[self.filter maximumValueForParameter:JFSLowPassFilterParamResonance] floatValue];
    self.resonanceSlider.value = [self.filter valueForParameter:JFSLowPassFilterParamResonance];
    
    self.cutoffLFOSlider.minimumValue = [[self.lfo minimumValueForParameter:JFSLFOParameterRate] floatValue];
    self.cutoffLFOSlider.maximumValue = [[self.lfo maximumValueForParameter:JFSLFOParameterRate] floatValue];
    self.cutoffLFOSlider.value = [self.lfo valueForParameter:JFSLFOParameterRate];
    
    self.lfoAmountSlider.minimumValue = [[self.lfo minimumValueForParameter:JFSLFOParameterAmount] floatValue];
    self.lfoAmountSlider.maximumValue = [[self.lfo maximumValueForParameter:JFSLFOParameterAmount] floatValue];
    self.lfoAmountSlider.value = [self.lfo valueForParameter:JFSLFOParameterAmount];
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    if (knob == self.cutoffSlider || knob == self.resonanceSlider) {
        [self.filter setValue:knob.value forParameter:knob.tag];
    } else {
        [self.lfo setValue:knob.value forParameter:knob.tag];
    }
}

@end
