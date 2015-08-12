//
//  PreferenceBanner.h
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/12/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BubbleTeaStore;

@interface PreferenceBanner : UIView
@property (nonatomic, strong, setter=setStore:) BubbleTeaStore *preferredStore;
@end
