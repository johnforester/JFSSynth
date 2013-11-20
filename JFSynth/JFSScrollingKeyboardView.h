//
//  JFSKeyboardView.h
//  JFSynth
//
//  Created by jforester on 11/19/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFSKeyboardViewDelegate <NSObject>

- (void)keyPressedWithMidiNote:(int)midiNote;
- (void)keyReleasedWithMidiNote:(int)midiNote;

@end

@interface JFSScrollingKeyboardView : UIView

@property (nonatomic, assign) id<JFSKeyboardViewDelegate> delegate;

@end
