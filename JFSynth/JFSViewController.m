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

@property (weak, nonatomic) IBOutlet UISlider *oscOneCoarseSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscTwoCoarseSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscOneFineSlider;
@property (weak, nonatomic) IBOutlet UISlider *oscTwoFineSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSEnvelopeView *filterEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.keyBoardView.delegate = self;
    
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
    
    self.lfoAmountSlider.value = [audioManager cuttoffLFOAmount];
    
    self.oscOneCoarseSlider.value = audioManager.oscillatorOne.coarse;
    self.oscTwoCoarseSlider.value = audioManager.oscillatorTwo.coarse;
    self.oscOneFineSlider.value = audioManager.oscillatorOne.fine;
    self.oscTwoFineSlider.value = audioManager.oscillatorTwo.fine;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBAction

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedManager].oscillatorOne setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)waveTypeTwoControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedManager].oscillatorTwo setWaveType:segmentedControl.selectedSegmentIndex];
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

- (IBAction)filterLFOAmountSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager] updateLFOAmount:slider.value];
}

- (IBAction)oscOneCoarseSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager]updateOscillator:[JFSSynthController sharedManager].oscillatorOne coarse:slider.value];
}

- (IBAction)oscTwoCoarseSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager]updateOscillator:[JFSSynthController sharedManager].oscillatorTwo coarse:slider.value];
}

- (IBAction)oscOneFineSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager]updateOscillator:[JFSSynthController sharedManager].oscillatorOne fine:slider.value];
}

- (IBAction)oscTwoFineSliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedManager]updateOscillator:[JFSSynthController sharedManager].oscillatorTwo fine:slider.value];
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

- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint value:(Float32)value
{
    JFSEnvelopeGenerator *envelopeGenerator;
    
    if (envelopeView == self.ampEnvelopeView) {
        envelopeGenerator = [JFSSynthController sharedManager].ampEnvelopeGenerator;
    } else {
        envelopeGenerator = [JFSSynthController sharedManager].filterEnvelopeGenerator;
    }
    
    switch (envelopePoint) {
        case JFSEnvelopeViewPointAttack:
            envelopeGenerator.attackTime = value;
            break;
        case JFSEnvelopeViewPointDecay:
            envelopeGenerator.decayTime = value;
            break;
        case JFSEnvelopeViewPointSustain:
            [envelopeGenerator updateSustainWithMidiVelocity:value * 127.];
            break;
        case JFSEnvelopeViewPointRelease:
            envelopeGenerator.releaseTime = value;
            break;
        default:
            break;
    }
}

#pragma mark - JFSKeyboardViewDelegate

- (void)keyPressedWithMidiNote:(int)midiNote
{
    double frequency = pow(2, (double)(midiNote - 69) / 12) * 440;
    
    [[JFSSynthController sharedManager] playFrequency:frequency];
}

- (void)keyReleasedWithMidiNote:(int)midiNote
{
    [[JFSSynthController sharedManager] stopPlaying];
}

@end
