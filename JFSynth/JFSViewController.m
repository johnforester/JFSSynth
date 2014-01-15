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
#import "JFSEnvelopeViewController.h"

@interface JFSViewController ()

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

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

@property (weak, nonatomic) IBOutlet JFSKnob *distortionMixKnob;
@property (weak, nonatomic) IBOutlet JFSKnob *distortionGainKnob;

@property (weak, nonatomic) IBOutlet UIView *ampEnvelopeContainerView;
@property (weak, nonatomic) IBOutlet UIView *filterEnvelopeContainerView;

@property (strong, nonatomic) JFSEnvelopeViewController *ampEnvelopeViewController;
@property (strong, nonatomic) JFSEnvelopeViewController *filterEnvelopeViewController;

@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;

@property (nonatomic, strong) NSTimer *refreshTimer;

@property (weak, nonatomic) IBOutlet UIProgressView *dbProgressView;

@end

@implementation JFSViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.keyBoardView.delegate = self;
        
        JFSSynthController *synthController = [JFSSynthController sharedController];
        
        self.ampEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.ampEnvelopeGenerator];
        self.filterEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.filterEnvelopeGenerator];
        
        self.ampEnvelopeViewController.view.frame = self.ampEnvelopeContainerView.bounds;
        [self.ampEnvelopeContainerView addSubview:self.ampEnvelopeViewController.view];
        [self addChildViewController:self.ampEnvelopeViewController];
        
        self.filterEnvelopeViewController.view.frame = self.filterEnvelopeContainerView.bounds;
        [self.filterEnvelopeContainerView addSubview:self.filterEnvelopeViewController.view];
        [self addChildViewController:self.filterEnvelopeViewController];
        
        self.velocityPeakSlider.minimumValue = [synthController minimumVelocity];
        self.velocityPeakSlider.maximumValue = [synthController maximumVelocity];
        self.velocityPeakSlider.value = synthController.ampEnvelopeGenerator.midiVelocity;
        
        self.cutoffSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamCutoff] floatValue];
        self.cutoffSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamCutoff] floatValue];
        self.cutoffSlider.value = [synthController valueForParameter:JFSSynthParamCutoff];
        
        self.resonanceSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamResonance] floatValue];
        self.resonanceSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamResonance] floatValue];
        self.resonanceSlider.value = [synthController valueForParameter:JFSSynthParamResonance];
        
        self.cutoffLFOSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamCutoffLFORate] floatValue];
        self.cutoffLFOSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamCutoffLFORate] floatValue];
        self.cutoffLFOSlider.value = [synthController valueForParameter:JFSSynthParamCutoffLFORate];
        
        self.lfoAmountSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamCutoffLFOAmount] floatValue];
        self.lfoAmountSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamCutoffLFOAmount] floatValue];
        self.lfoAmountSlider.value = [synthController valueForParameter:JFSSynthParamCutoffLFOAmount];
        
        self.oscOneSemitoneSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator1Semitones] floatValue];
        self.oscOneSemitoneSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator1Semitones] floatValue];
        self.oscTwoSemitoneSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator2Semitones] floatValue];
        self.oscTwoSemitoneSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator2Semitones] floatValue];
        
        self.oscOneFineSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator1Fine] floatValue];
        self.oscOneFineSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator1Fine] floatValue];
        self.oscTwoFineSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamOscillator2Fine] floatValue];
        self.oscTwoFineSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamOscillator2Fine] floatValue];
        
        self.oscOneVolumeSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthControllerOscillator1Volume] floatValue];
        self.oscOneVolumeSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthControllerOscillator1Volume] floatValue];
        self.oscOneVolumeSlider.value = [synthController valueForParameter:JFSSynthControllerOscillator1Volume];
        
        self.oscTwoVolumeSlider.minimumValue = [[synthController minimumValueForParameter:JFSSynthControllerOscillator2Volume] floatValue];;
        self.oscTwoVolumeSlider.maximumValue = [[synthController maximumValueForParameter:JFSSynthControllerOscillator2Volume] floatValue];;
        self.oscTwoVolumeSlider.value = [synthController valueForParameter:JFSSynthControllerOscillator2Volume];
        
        self.oscOneSemitoneSlider.displayType = JFSKnobDisplayTypeInteger;
        self.oscTwoSemitoneSlider.displayType = JFSKnobDisplayTypeInteger;
        
        self.oscOneSemitoneSlider.value = [synthController.oscillators[0] semitones];
        self.oscTwoSemitoneSlider.value = [synthController.oscillators[1] semitones];
        
        self.oscOneFineSlider.value = [synthController.oscillators[0] fine];
        self.oscTwoFineSlider.value = [synthController.oscillators[1] fine];
        
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
        
        self.distortionGainKnob.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDistortionGain] floatValue];
        self.distortionGainKnob.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDistortionGain] floatValue];
        self.distortionGainKnob.value = [synthController valueForParameter:JFSSynthParamDistortionGain];
        
        self.distortionMixKnob.minimumValue = [[synthController minimumValueForParameter:JFSSynthParamDistortionMix] floatValue];
        self.distortionMixKnob.maximumValue = [[synthController maximumValueForParameter:JFSSynthParamDistortionMix] floatValue];
        self.distortionMixKnob.value = [synthController valueForParameter:JFSSynthParamDistortionMix];
        
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(refreshViews) userInfo:nil repeats:YES];
        [self.refreshTimer fire];
    });
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
    [self.ampEnvelopeViewController refresh];
    [self.filterEnvelopeViewController refresh];
    
    Float32 outputlevel = [[JFSSynthController sharedController] outputLevel];
    
    outputlevel = MAX(-20, outputlevel);
    outputlevel = MIN(0, outputlevel);
    self.levelLabel.text = [NSString stringWithFormat:@"%.2f dB", outputlevel];

    self.dbProgressView.progress = (outputlevel + 20)/ 20;
}

#pragma mark - IBAction

- (IBAction)waveTypeControlChanged:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.tag < [[[JFSSynthController sharedController] oscillators] count]) {
        [[JFSSynthController sharedController].oscillators[segmentedControl.tag] setWaveType:segmentedControl.selectedSegmentIndex];
    } else {
        [[JFSSynthController sharedController].cutoffLFO setWaveType:segmentedControl.selectedSegmentIndex];
    }
}

- (IBAction)knobValueChanged:(JFSKnob *)knob
{
    [[JFSSynthController sharedController] setValue:knob.value forParameter:knob.tag];
}

- (IBAction)velocitySliderChanged:(UISlider *)slider
{
    [[JFSSynthController sharedController].ampEnvelopeGenerator setMidiVelocity:slider.value];
}

- (IBAction)delaySwitchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDelay:sender.isOn];
}

- (IBAction)distortionSwitchChanged:(UISwitch *)sender
{
    [[JFSSynthController sharedController] toggleDistortion:sender.isOn];
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
