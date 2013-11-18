//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthController.h"
#import "JFSEnvelopeGenerator.h"
#import "JFSOscillator.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet UISlider *cutoffSlider;
@property (weak, nonatomic) IBOutlet UISlider *resonanceSlider;
@property (weak, nonatomic) IBOutlet UISlider *cutoffLFOSlider;

@property (weak, nonatomic) IBOutlet UISlider *noteSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ampEnvelopeView.dataSource = self;
    self.ampEnvelopeView.delegate = self;
    
    JFSSynthController *audioManager = [JFSSynthController sharedManager];
    
    self.velocityPeakSlider.minimumValue = 0.001;
    self.velocityPeakSlider.maximumValue = 127.0;
    self.velocityPeakSlider.value = 60;
    
    self.cutoffSlider.minimumValue = [audioManager minimumCutoff];
    self.cutoffSlider.maximumValue = [audioManager maximumCutoff];
    self.cutoffSlider.value = audioManager.cutoffLevel;
    
    self.cutoffLFOSlider.minimumValue = [audioManager minimumCutoffLFO];
    self.cutoffLFOSlider.maximumValue = [audioManager maximumCutoffLFO];
    
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

- (IBAction)play:(id)sender
{
    double note = pow(2, ((int)self.noteSlider.value - 69) / 12) * 440;
    
    [[JFSSynthController sharedManager] playFrequency:note];
}

- (IBAction)noteSliderChanged:(id)sender
{
    double note = pow(2, ((int)self.noteSlider.value - 69) / 12) * 440;
    
    [[JFSSynthController sharedManager] updateFrequency:note];
}

- (IBAction)stop:(id)sender
{
    [[JFSSynthController sharedManager] stopPlaying];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedManager].oscillator setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)peakSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager].ampEnvelopeGenerator updatePeakWithMidiVelocity:slider.value];
}

- (IBAction)cutoffSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedManager].cutoffLevel = slider.value;
}

- (IBAction)resonanceSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedManager].resonanceLevel = slider.value;
}
- (IBAction)cutoffLFOSLiderChanged:(UISlider *)slider
{
    [JFSSynthController sharedManager].cutoffLFOFrequency = slider.value;
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTime;
{
    return [JFSSynthController sharedManager].ampEnvelopeGenerator.attackTime;
}

- (Float32)decayTime
{
    return [JFSSynthController sharedManager].ampEnvelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeak
{
    return [JFSSynthController sharedManager].ampEnvelopeGenerator.sustainLevel / [JFSSynthController sharedManager].ampEnvelopeGenerator.peak;
}

- (Float32)releaseTime
{
    return [JFSSynthController sharedManager].ampEnvelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTime
{
    return [JFSSynthController sharedManager].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint adjustedPoint:(CGPoint)point
{
    CGFloat width = CGRectGetWidth(envelopView.frame);
    CGFloat height = CGRectGetHeight(envelopView.frame);
    
    CGFloat timeValue = (point.x / (width/3)) * [self maxEnvelopeTime];
    
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            [JFSSynthController sharedManager].ampEnvelopeGenerator.attackTime = timeValue;
            NSLog(@"attack %f", timeValue);
            break;
        case JFSEnvelopeViewPointDecay:
            
            [JFSSynthController sharedManager].ampEnvelopeGenerator.decayTime = timeValue;
            
            [[JFSSynthController sharedManager].ampEnvelopeGenerator updateSustainWithMidiVelocity:((height - point.y) / height) * 127.];
            
            NSLog(@"decay %f",timeValue);
            NSLog(@"sustain %f", [JFSSynthController sharedManager].ampEnvelopeGenerator.sustainLevel);
            break;
        case JFSEnvelopeViewPointSustainEnd:
            break;
        case JFSEnvelopeViewPointRelease:
            [JFSSynthController sharedManager].ampEnvelopeGenerator.releaseTime = timeValue;
            
            NSLog(@"release %f", timeValue);
            break;
        default:
            break;
    }
}

@end
