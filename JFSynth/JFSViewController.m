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
#import "JFSKnob.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet JFSKnob *cutoffSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *resonanceSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *cutoffLFOSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *lfoAmountSlider;

@property (weak, nonatomic) IBOutlet JFSKnob *oscOneVolumeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *oscTwoVolumeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *oscOneSemitoneSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *oscTwoSemitoneSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *oscOneFineSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *oscTwoFineSlider;

@property (weak, nonatomic) IBOutlet JFSKnob *delayDryWetSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayFeedbackSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayTimeSlider;
@property (weak, nonatomic) IBOutlet JFSKnob *delayCutoffSlider;

@property (weak, nonatomic) IBOutlet JFSEnvelopeView *ampEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSEnvelopeView *filterEnvelopeView;
@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;


@property (nonatomic, strong) NSTimer *refreshTimer;

@property (weak, nonatomic) IBOutlet UILabel *oscOneSemitoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *oscTwoSemitoneLabel;

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
    
    JFSSynthController *synthController = [JFSSynthController sharedController];
    
    self.velocityPeakSlider.minimumValue = [synthController minimumVelocity];
    self.velocityPeakSlider.maximumValue = [synthController maximumVelocity];
    self.velocityPeakSlider.value = synthController.ampEnvelopeGenerator.peak;
    
    self.cutoffSlider.minimumValue = [synthController minimumCutoff];
    self.cutoffSlider.maximumValue = [synthController maximumCutoff];
    self.cutoffSlider.value = [synthController cutoffLevel];
    
    self.resonanceSlider.minimumValue = [synthController minimumResonance];
    self.resonanceSlider.maximumValue = [synthController maximumResonance];
    self.resonanceSlider.value = [synthController resonanceLevel];
    
    self.cutoffLFOSlider.minimumValue = [synthController minimumCutoffLFO];
    self.cutoffLFOSlider.maximumValue = [synthController maximumCutoffLFO];
    self.cutoffLFOSlider.value = 0;
    
    self.lfoAmountSlider.minimumValue = 0;
    self.lfoAmountSlider.maximumValue = 1;
    self.lfoAmountSlider.value = [synthController cuttoffLFOAmount];
    
    self.oscOneSemitoneSlider.minimumValue = [synthController minimumSemitones];
    self.oscOneSemitoneSlider.maximumValue = [synthController maximumSemitones];
    self.oscTwoSemitoneSlider.minimumValue = [synthController minimumSemitones];
    self.oscTwoSemitoneSlider.maximumValue = [synthController maximumSemitones];
    
    self.oscOneFineSlider.minimumValue = [synthController minimumFine];
    self.oscOneFineSlider.maximumValue = [synthController maximumFine];
    self.oscTwoFineSlider.minimumValue = [synthController minimumFine];
    self.oscTwoFineSlider.maximumValue = [synthController maximumFine];
    
    self.oscOneVolumeSlider.minimumValue = 0;
    self.oscOneVolumeSlider.maximumValue = 1;
    self.oscOneVolumeSlider.value = 0.7;
    
    self.oscTwoVolumeSlider.minimumValue = 0;
    self.oscTwoVolumeSlider.maximumValue = 1;
    self.oscTwoVolumeSlider.value = 0.7;
    
    self.oscOneSemitoneSlider.value = [synthController.oscillators[0] semitones];
    self.oscTwoSemitoneSlider.value = [synthController.oscillators[1] semitones];
    self.oscOneSemitoneLabel.text = [NSString stringWithFormat:@"%+d",(int)self.oscOneSemitoneSlider.value];
    self.oscTwoSemitoneLabel.text = [NSString stringWithFormat:@"%+d",(int)self.oscTwoSemitoneSlider.value];
    
    self.oscOneFineSlider.value = [synthController.oscillators[0] fine];
    self.oscTwoFineSlider.value = [synthController.oscillators[1] fine];
    
    self.delayDryWetSlider.minimumValue = [synthController minimumDelayDryWet];
    self.delayDryWetSlider.maximumValue = [synthController maximumDelayDryWet];
    self.delayDryWetSlider.value = [synthController delayDryWet];
    
    self.delayFeedbackSlider.minimumValue = [synthController minimumDelayFeedback];
    self.delayFeedbackSlider.maximumValue = [synthController maximumDelayFeedback];
    self.delayFeedbackSlider.value = [synthController delayFeedback];
    
    self.delayCutoffSlider.minimumValue = [synthController minimumDelayCutoff];
    self.delayCutoffSlider.maximumValue = [synthController maximumDelayCutoff];
    self.delayCutoffSlider.value = [synthController delayCutoff];
    
    self.delayTimeSlider.minimumValue = [synthController minimumDelayTime];
    self.delayTimeSlider.maximumValue = [synthController maximumDelayTime];
    self.delayTimeSlider.value = [synthController delayTime];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(refreshViews) userInfo:nil repeats:YES];
    
    [self.refreshTimer fire];
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

- (void)dealloc
{
    [self.refreshTimer invalidate];
}

#pragma mark - UI Refresh

- (void)refreshViews
{
    [self.ampEnvelopeView updateStageViewWithStage:[JFSSynthController sharedController].ampEnvelopeGenerator.envelopeState - 1];
    [self.filterEnvelopeView updateStageViewWithStage:[JFSSynthController sharedController].filterEnvelopeGenerator.envelopeState - 1];
}

#pragma mark - IBAction

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    [[JFSSynthController sharedController].oscillators[segmentedControl.tag] setWaveType:segmentedControl.selectedSegmentIndex];
}

- (IBAction)velocitySliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController].ampEnvelopeGenerator setMidiVelocity:slider.value];
}

- (IBAction)cutoffSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setCutoffKnobLevel:slider.value];
}

- (IBAction)resonanceSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController]setResonanceLevel:slider.value];
}

- (IBAction)cutoffLFOSliderChanged:(JFSKnob *)slider
{
    [JFSSynthController sharedController].cutoffLFOFrequency = slider.value;
}

- (IBAction)filterLFOAmountSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setCutoffLFOAmount:slider.value];
}

- (IBAction)semiToneSliderChanged:(JFSKnob *)slider
{
    int tag = slider.tag;
    
    UILabel *semitoneLabel;
    
    if (tag == 0) {
        semitoneLabel = self.oscOneSemitoneLabel;
    } else {
        semitoneLabel = self.oscTwoSemitoneLabel;
    }
    
    int semitone = (int)round(slider.value);
    semitoneLabel.text = [NSString stringWithFormat:@"%+d",semitone];
    
    [[JFSSynthController sharedController] setSemitonesForOscillatorAtIndex:slider.tag value:semitone];
}

- (IBAction)oscOneFineSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setFineForOscillatorAtIndex:slider.tag value:slider.value];
}

- (IBAction)oscillatorVolumeSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setVolumeForOscillatorAtIndex:slider.tag value:slider.value];
}

- (IBAction)delayWetDrySliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setDelayWetDry:slider.value];
}

- (IBAction)delayFeedbackSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setDelayFeedback:slider.value];
}

- (IBAction)delayTimeSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setDelayTime:slider.value];
}

- (IBAction)delayCutoffSliderChanged:(JFSKnob *)slider
{
    [[JFSSynthController sharedController] setDelayCutoff:slider.value];
}

#pragma mark - JFSEnvelopeViewDataSource

- (Float32)attackTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.attackTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.attackTime;
}

- (Float32)decayTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.decayTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.decayTime;
}

- (Float32)sustainPercentageOfPeakForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.sustainLevel / [JFSSynthController sharedController].ampEnvelopeGenerator.peak;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.sustainLevel / [JFSSynthController sharedController].filterEnvelopeGenerator.peak;
}

- (Float32)releaseTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    if (envelopeView == self.ampEnvelopeView) {
        return [JFSSynthController sharedController].ampEnvelopeGenerator.releaseTime;
    }
    
    return [JFSSynthController sharedController].filterEnvelopeGenerator.releaseTime;
}

- (Float32)maxEnvelopeTimeForEnvelopeView:(JFSEnvelopeView *)envelopeView
{
    return [JFSSynthController sharedController].maximumEnvelopeTime;
}

#pragma mark - JFSEnvelopeViewDelegate

- (void)envelopeView:(JFSEnvelopeView *)envelopeView didUpdateEnvelopePoint:(JFSEnvelopeViewStagePoint)envelopePoint value:(Float32)value
{
    JFSEnvelopeGenerator *envelopeGenerator;
    
    if (envelopeView == self.ampEnvelopeView) {
        envelopeGenerator = [JFSSynthController sharedController].ampEnvelopeGenerator;
    } else {
        envelopeGenerator = [JFSSynthController sharedController].filterEnvelopeGenerator;
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
    [[JFSSynthController sharedController] playMidiNote:midiNote];
}

- (void)keyReleasedWithMidiNote:(int)midiNote
{
    [[JFSSynthController sharedController] stopPlaying];
}

@end
