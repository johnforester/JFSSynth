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
@property (weak, nonatomic) IBOutlet UISlider *lfoAmountSlider;

@property (weak, nonatomic) IBOutlet UISlider *noteSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSEnvelopeView *filterEnvelopeView;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ampEnvelopeView.dataSource = self;
    self.ampEnvelopeView.delegate = self;
    
    self.filterEnvelopeView.dataSource = self;
    self.filterEnvelopeView.delegate = self;
    
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
- (IBAction)cutoffLFOSliderChanged:(UISlider *)slider
{
    [JFSSynthController sharedManager].cutoffLFOFrequency = slider.value;
}

- (IBAction)filterLFOAmountSliderChanged:(id)sender
{
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedManager].ampEnvelopeGenerator.attackTime;
    }
    
    return [JFSSynthController sharedManager].filterEnvelopeGenerator.attackTime;
}

- (Float32)decayTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedManager].ampEnvelopeGenerator.decayTime;
    }
    
    return [JFSSynthController sharedManager].filterEnvelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeakForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedManager].ampEnvelopeGenerator.sustainLevel / [JFSSynthController sharedManager].ampEnvelopeGenerator.peak;
    }
    
    return [JFSSynthController sharedManager].filterEnvelopeGenerator.sustainLevel / [JFSSynthController sharedManager].filterEnvelopeGenerator.peak;
}

- (Float32)releaseTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedManager].ampEnvelopeGenerator.releaseTime;
    }
    
    return [JFSSynthController sharedManager].filterEnvelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return [JFSSynthController sharedManager].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint adjustedPoint:(CGPoint)point
{
    CGFloat width = CGRectGetWidth(envelopeView.frame);
    CGFloat height = CGRectGetHeight(envelopeView.frame);
    
    CGFloat timeValue = (point.x / (width/3)) * [self maxEnvelopeTimeForEnvelopeView:envelopeView];
    
    JFSEnvelopeGenerator *envelopeGenerator;
    
    if (envelopeView == self.ampEnvelopeView) {
        envelopeGenerator = [JFSSynthController sharedManager].ampEnvelopeGenerator;
    } else {
        envelopeGenerator = [JFSSynthController sharedManager].filterEnvelopeGenerator;
    }
    
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            envelopeGenerator.attackTime = timeValue;
            break;
        case JFSEnvelopeViewPointDecay:
            envelopeGenerator.decayTime = timeValue;
            [envelopeGenerator updateSustainWithMidiVelocity:((height - point.y) / height) * 127.];
            break;
        case JFSEnvelopeViewPointSustainEnd:
            break;
        case JFSEnvelopeViewPointRelease:
            envelopeGenerator.releaseTime = timeValue;
            break;
        default:
            break;
    }
}

@end
