//
//  PreferenceBanner.m
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/12/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#import "PreferenceBanner.h"
#import "BubbleTeaStore.h"
#import "Location.h"

@interface PreferenceBanner ()
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end

@implementation PreferenceBanner

@synthesize preferredStore = _preferredStore;

- (void)setStore:(BubbleTeaStore *)store {
    _preferredStore = store;
    self.distanceLabel.text = [NSString stringWithFormat:@"%@", _preferredStore.location.distance ? _preferredStore.location.distance : 0];
    self.nameLabel.text = [NSString stringWithString:_preferredStore.title ? _preferredStore.title : @"No Title?"];
    self.addressLabel.text = [NSString stringWithString:_preferredStore.subtitle ? _preferredStore.subtitle : @"No Address?"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
