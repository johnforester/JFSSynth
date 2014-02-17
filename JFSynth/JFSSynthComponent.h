//
//  JFSSynthComponent.h
//  JFSynth
//
//  Created by John Forester on 2/17/14.
//  Copyright (c) 2014 John Forester. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSInteger JFSSynthParameter;

@protocol JFSSynthComponent <NSObject>

@required
- (NSNumber *)minimumValueForParameter:(JFSSynthParameter)parameter;
- (NSNumber *)maximumValueForParameter:(JFSSynthParameter)parameter;

@end
