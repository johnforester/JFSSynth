//
//  JFSViewController.m
//  JFSynth
//
//  Created by John Forester on 10/27/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import "JFSViewController.h"
#import "JFSSynthManager.h"
#import "JFSEnvelopeGenerator.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *attackSlider;
@property (weak, nonatomic) IBOutlet UISlider *decaySlider;
@property (weak, nonatomic) IBOutlet UISlider *sustainSlider;
@property (weak, nonatomic) IBOutlet UISlider *releaseSlider;
@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet UISlider *cutoffSlider;
@property (weak, nonatomic) IBOutlet UISlider *resonanceSlider;

@property (weak, nonatomic) IBOutlet UISlider *noteSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ampEnvelopeView.dataSource = self;
    self.ampEnvelopeView.delegate = self;
    
    JFSSynthManager *audioManager = [JFSSynthManager sharedManager];
    
    //TODO move min and max to audio manager
    
    self.attackSlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.attackSlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.attackSlider.value = audioManager.ampEnvelopeGenerator.attackTime;
    
    self.velocityPeakSlider.minimumValue = 0.001;
    self.velocityPeakSlider.maximumValue = 127.0;
    self.velocityPeakSlider.value = audioManager.ampEnvelopeGenerator.peak;
    
    self.decaySlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.decaySlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.decaySlider.value = audioManager.ampEnvelopeGenerator.decayTime;
    
    self.sustainSlider.minimumValue = 0;
    self.sustainSlider.maximumValue = 127;
    self.sustainSlider.value = 60;
    
    self.releaseSlider.minimumValue = [audioManager minimumEnvelopeTime];
    self.releaseSlider.maximumValue = [audioManager maximumEnvelopeTime];
    self.releaseSlider.value = audioManager.ampEnvelopeGenerator.releaseTime;
    
    self.cutoffSlider.minimumValue = [audioManager minimumCutoff];
    self.cutoffSlider.maximumValue = [audioManager maximumCutoff];
    self.cutoffSlider.value = audioManager.cutoffLevel;
    
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
    
    [[JFSSynthManager sharedManager] playFrequency:note];
}

- (IBAction)noteSliderChanged:(id)sender
{
    double note = pow(2, ((int)self.noteSlider.value - 69) / 12) * 440;
    
    [[JFSSynthManager sharedManager] updateFrequency:note];
}

- (IBAction)stop:(id)sender
{
    [[JFSSynthManager sharedManager] stopPlaying];
}

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthManager sharedManager] setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)peakSliderChanged:(UISlider *)slider
{
    [[JFSSynthManager sharedManager].ampEnvelopeGenerator updatePeakWithMidiVelocity:slider.value];
}

- (IBAction)cutoffSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].cutoffLevel = slider.value;
}

- (IBAction)resonanceSliderChanged:(UISlider *)slider
{
    [JFSSynthManager sharedManager].resonanceLevel = slider.value;
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTime;
{
    return [JFSSynthManager sharedManager].ampEnvelopeGenerator.attackTime;
}

- (Float32)decayTime
{
    return [JFSSynthManager sharedManager].ampEnvelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeak
{
    return [JFSSynthManager sharedManager].ampEnvelopeGenerator.sustainLevel / [JFSSynthManager sharedManager].ampEnvelopeGenerator.peak;
}

- (Float32)releaseTime
{
    return [JFSSynthManager sharedManager].ampEnvelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTime
{
    return [JFSSynthManager sharedManager].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopView didUpdateEnvelopePoint:(JFSEnvelopeViewSegmentPoint)envelopePoint adjustedPoint:(CGPoint)point
{
    CGFloat width = CGRectGetWidth(envelopView.frame);
    CGFloat height = CGRectGetHeight(envelopView.frame);
    
    CGFloat timeValue = (point.x / (width/3)) * [self maxEnvelopeTime];
    
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            [JFSSynthManager sharedManager].ampEnvelopeGenerator.attackTime = timeValue;
            NSLog(@"attack %f", timeValue);
            break;
        case JFSEnvelopeViewPointDecay:
            
            [JFSSynthManager sharedManager].ampEnvelopeGenerator.decayTime = timeValue;
            
            [[JFSSynthManager sharedManager].ampEnvelopeGenerator updateSustainWithMidiVelocity:((height - point.y) / height) * 127.];
            
            NSLog(@"decay %f",timeValue);
            NSLog(@"sustain %f", [JFSSynthManager sharedManager].ampEnvelopeGenerator.sustainLevel);
            break;
        case JFSEnvelopeViewPointSustainEnd:
            break;
        case JFSEnvelopeViewPointRelease:
            [JFSSynthManager sharedManager].ampEnvelopeGenerator.releaseTime = timeValue;
            
            NSLog(@"release %f", timeValue);
            break;
        default:
            break;
    }
}

@end
