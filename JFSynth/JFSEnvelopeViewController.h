//
//  JFSEnvelopeViewController.h
//  JFSynth
//
//  Created by jforester on 1/10/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JFSEnvelopeGenerator;

@interface JFSEnvelopeViewController : UIViewController

- (instancetype)initWithEnvelope:(JFSEnvelopeGenerator *)envelopeGenerator;
- (void)refresh;

@end
