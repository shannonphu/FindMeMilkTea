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
    return [NSString stringWithFormat:@"%@ %@, %@, %@, %@", self.location.address, self.location.city, self.location.state, self.location.country, self.location.postalCode];
}

- (NSComparisonResult)compare:(BubbleTeaStore *)otherStore {
    
    return [self.location.distance compare:otherStore.location.distance];
}

@end
