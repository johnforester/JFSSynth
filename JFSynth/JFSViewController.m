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
#import "JFSDelayViewController.h"
#import "JFSDistortionViewController.h"

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

@property (weak, nonatomic) IBOutlet UIView *envelopeContainerView;

@property (weak, nonatomic) IBOutlet UIProgressView *dbProgressView;

@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;

@property (weak, nonatomic) IBOutlet UIView *effectsContainerView;

@property (strong, nonatomic) JFSEnvelopeViewController *ampEnvelopeViewController;
@property (strong, nonatomic) JFSEnvelopeViewController *filterEnvelopeViewController;
@property (nonatomic, strong) UIViewController *currentEnvelopeViewController;

@property (nonatomic, strong) NSTimer *refreshTimer;

@property (nonatomic, strong) JFSDelayViewController *delayViewController;
@property (nonatomic, strong) JFSDistortionViewController *distortionViewController;
@property (nonatomic, strong) UIViewController *currentEffectViewController;

@end

@implementation JFSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JFSSynthController *synthController = [JFSSynthController sharedController];
    
    self.delayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DelayViewController"];
    self.distortionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DistortionViewController"];
    
    [self displayEffectViewControllerWithIndex:0];
    
    self.effectsContainerView.layer.borderColor = [UIColor redColor].CGColor;
    self.effectsContainerView.layer.borderWidth = 1.0;
    
    self.keyBoardView.delegate = self;
    
    self.ampEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.ampEnvelopeGenerator];
    self.filterEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.filterEnvelopeGenerator];
    
    [self displayEnvelopeViewControllerWithIndex:0];
    
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
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(refreshViews) userInfo:nil repeats:YES];
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
    [self.ampEnvelopeViewController refresh];
    [self.filterEnvelopeViewController refresh];
    
    Float32 outputlevel = [[JFSSynthController sharedController] outputLevel];
    
    outputlevel = MAX(-20, outputlevel);
    outputlevel = MIN(0, outputlevel);
    self.levelLabel.text = [NSString stringWithFormat:@"%.2f dB", outputlevel];
    
    self.dbProgressView.progress = (outputlevel + 20) / 20;
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

- (IBAction)effectSwitchChanged:(UISegmentedControl *)sender
{
    [self displayEffectViewControllerWithIndex:sender.selectedSegmentIndex];
}

- (IBAction)envelopeSwitchChanged:(UISegmentedControl *)sender
{
    [self displayEnvelopeViewControllerWithIndex:sender.selectedSegmentIndex];
}

- (void)displayEffectViewControllerWithIndex:(int)idx
{
    UIViewController *nextEffectVC;
    
    if (idx == 0) {
        nextEffectVC = self.distortionViewController;
    } else {
        nextEffectVC = self.delayViewController;
    }
    
    [self.currentEffectViewController removeFromParentViewController];
    [self.currentEffectViewController.view removeFromSuperview];
    
    [self.effectsContainerView addSubview:nextEffectVC.view];
    [self addChildViewController:nextEffectVC];
    self.currentEffectViewController = nextEffectVC;
}

- (void)displayEnvelopeViewControllerWithIndex:(int)idx
{
    UIViewController *nextEnvelopeVC;
    
    if (idx == 0) {
        nextEnvelopeVC = self.ampEnvelopeViewController;
    } else {
        nextEnvelopeVC = self.filterEnvelopeViewController;
    }
    
    [self.currentEnvelopeViewController removeFromParentViewController];
    [self.currentEnvelopeViewController.view removeFromSuperview];
    
    [self.envelopeContainerView addSubview:nextEnvelopeVC.view];
    [self addChildViewController:nextEnvelopeVC];
    self.currentEnvelopeViewController = nextEnvelopeVC;
    
    //update autolayout
    UIView *container = self.envelopeContainerView;
    UIView *amp = self.ampEnvelopeViewController.view;
    UIView *filter = self.filterEnvelopeViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(amp, filter);
    
    if (idx == 0) {
        [amp setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[amp]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[amp]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    } else {
        [filter setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[filter]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[filter]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
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
