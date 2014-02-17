//
//  JFSFilterViewController.h
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFSLowPassFilter, JFSOscillator;

@interface JFSFilterViewController : UIViewController

@property (nonatomic, strong) JFSLowPassFilter *filter;
@property (nonatomic, strong) JFSOscillator *lfo;

@end
