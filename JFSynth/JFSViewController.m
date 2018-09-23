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
#import "JFSEnvelopeViewController.h"
#import "JFSDelayViewController.h"
#import "JFSDistortionViewController.h"
#import "JFSOscillatorViewController.h"
#import "JFSFilterViewController.h"
#import "JFSEnvelopeView.h"
#import "JFSScrollingKeyboardView.h"

@interface JFSViewController ()<JFSKeyboardViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UISlider *velocityPeakSlider;

@property (weak, nonatomic) IBOutlet UIView *filterContainerView;

@property (strong, nonatomic) NSArray *oscillatorViewControllers;
@property (strong, nonatomic) JFSOscillatorViewController *currentOscillatorViewController;

@property (weak, nonatomic) IBOutlet UIView *oscillatorContainerView;

@property (weak, nonatomic) IBOutlet UIView *envelopeContainerView;

@property (weak, nonatomic) IBOutlet UIProgressView *dbProgressView;

@property (weak, nonatomic) IBOutlet JFSScrollingKeyboardView *keyBoardView;

@property (weak, nonatomic) IBOutlet UIView *effectsContainerView;

@property (strong, nonatomic) JFSFilterViewController *filterViewController;

@property (strong, nonatomic) JFSEnvelopeViewController *ampEnvelopeViewController;
@property (strong, nonatomic) JFSEnvelopeViewController *filterEnvelopeViewController;
@property (strong, nonatomic) UIViewController *currentEnvelopeViewController;

@property (strong, nonatomic) NSTimer *refreshTimer;

@property (strong, nonatomic) JFSDelayViewController *delayViewController;
@property (strong, nonatomic) JFSDistortionViewController *distortionViewController;
@property (strong, nonatomic) UIViewController *currentEffectViewController;

@end

@implementation JFSViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JFSSynthController *synthController = [JFSSynthController sharedController];
    
    NSMutableArray *tempOscViews = [[NSMutableArray alloc] init];
    
    [synthController.oscillators enumerateObjectsUsingBlock:^(JFSOscillator *oscillator, NSUInteger idx, BOOL *stop) {
        JFSOscillatorViewController *viewController = (JFSOscillatorViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OscillatorViewController"];
        viewController.oscillator = oscillator;
        [tempOscViews addObject:viewController];
    }];
    
    if ([tempOscViews count] > 0) {
        self.oscillatorViewControllers = [NSArray arrayWithArray:tempOscViews];
        
        [self displayOscillatorViewController:self.oscillatorViewControllers[0]];
    }
    
    self.filterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    self.filterViewController.filter = synthController.lpFilter;
    self.filterViewController.lfo = synthController.cutoffLFO;
    
    [self.filterContainerView addSubview:self.filterViewController.view];
    [self addChildViewController:self.filterViewController];
    
    UIView *filterView = self.filterViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(filterView);
    
    [filterView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.filterContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[filterView]|" options:0 metrics:nil views:views]];
    [self.filterContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[filterView]|" options:0 metrics:nil views:views]];
    
    self.delayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DelayViewController"];
    self.delayViewController.delay = synthController.delay;
    
    self.distortionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DistortionViewController"];
    self.distortionViewController.distortion = synthController.distortion;
    
    [self displayEffectViewControllerWithIndex:0];
    
    self.keyBoardView.delegate = self;
    
    self.ampEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.ampEnvelopeGenerator];
    self.filterEnvelopeViewController = [[JFSEnvelopeViewController alloc] initWithEnvelope:synthController.filterEnvelopeGenerator];
    
    [self displayEnvelopeViewControllerWithIndex:0];
    
    self.velocityPeakSlider.minimumValue = [synthController minimumVelocity];
    self.velocityPeakSlider.maximumValue = [synthController maximumVelocity];
    self.velocityPeakSlider.value = synthController.ampEnvelopeGenerator.midiVelocity;
    
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

- (IBAction)oscillatorSegmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    if ([self.oscillatorViewControllers count] > segmentedControl.selectedSegmentIndex) {
        [self displayOscillatorViewController:self.oscillatorViewControllers[segmentedControl.selectedSegmentIndex]];
    }
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

#pragma mark - view swapping

- (void)displayOscillatorViewController:(JFSOscillatorViewController *)oscillatorViewController
{
    UIView *view = oscillatorViewController.view;
    
    [self.currentOscillatorViewController removeFromParentViewController];
    [self.currentOscillatorViewController.view removeFromSuperview];
    
    [self addChildViewController:oscillatorViewController];
    [self.oscillatorContainerView addSubview:view];
    self.currentOscillatorViewController = oscillatorViewController;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);

    [view setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.oscillatorContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
    [self.oscillatorContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
}

- (void)displayEffectViewControllerWithIndex:(NSInteger)idx
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
    
    //update autolayout
    UIView *container = self.effectsContainerView;
    UIView *dist = self.distortionViewController.view;
    UIView *delay = self.delayViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(dist, delay);
    
    if (idx == 0) {
        [dist setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[dist]-20-|" options:0 metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[dist]-20-|" options:0 metrics:nil views:views]];
    } else {
        [delay setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[delay]-20-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[delay]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    }
}

- (void)displayEnvelopeViewControllerWithIndex:(NSInteger)idx
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
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[amp]-20-|" options:0 metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[amp]-20-|" options:0 metrics:nil views:views]];
    } else {
        [filter setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[filter]-20-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[filter]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
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
