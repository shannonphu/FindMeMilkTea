//
//  BubbleTeaStore.m
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/11/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#import "BubbleTeaStore.h"
#import <MapKit/MapKit.h>
#import "Location.h"

@interface BubbleTeaStore () <MKAnnotation>

@end

@implementation BubbleTeaStore
@synthesize location = _location;

-(CLLocationCoordinate2D) coordinate{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = self.location.lat.floatValue;
    coordinate.longitude = self.location.lng.floatValue;
    
    return coordinate;
}

- (NSString *)subtitle {
    NSString *address = self.location.address ? self.location.address : @"";
    NSString *city = self.location.city ? [NSString stringWithFormat:@"%@,", self.location.city] : @"";
    NSString *state = self.location.state ? [NSString stringWithFormat:@"%@", self.location.state] : @"";
    NSString *zip = self.location.postalCode ? self.location.postalCode : @"";
    NSRange range = [zip rangeOfString:@" "];
    if (range.location != NSNotFound) {
        zip = [zip substringFromIndex:(range.location + 1)];
    }
    return [NSString stringWithFormat:@"%@ %@ %@ %@", address, city, state, zip];
    
}

- (NSComparisonResult)compare:(BubbleTeaStore *)otherStore {
    
    return [self.location.distance compare:otherStore.location.distance];
}

@end
