//
//  BubbleTeaStore.h
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/11/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

@class Location;
@class Contact;
#import <Foundation/Foundation.h>

@interface BubbleTeaStore : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *menuURL;

@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) Contact *contact;

@end
