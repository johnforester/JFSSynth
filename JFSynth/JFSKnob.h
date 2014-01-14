//
//  JFSKnob.h
//  JFSynth
//
//  Created by jforester on 11/22/13.
//  Copyright (c) 2013 John Forester. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JFSKnobDisplayType) {
    JFSKnobDisplayTypeFloat,
    JFSKnobDisplayTypeInteger
};

@interface JFSKnob : UIControl

@property (nonatomic, assign) Float32 minimumValue;
@property (nonatomic, assign) Float32 maximumValue;
@property (nonatomic, assign) Float32 value;
@property (nonatomic, assign) JFSKnobDisplayType displayType;

@end
