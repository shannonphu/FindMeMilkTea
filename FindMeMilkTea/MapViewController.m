//
//  MapViewController.m
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/11/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#define CLIENTID @"CJBPZ34CNPG4PYTUCS3P3USRIFPCACOLMIG3AXLWUUTFHVAH"
#define CLIENTSECRET @"RQXJG2EUBGRVRKJA2ZJEG1QA0GATV1KFFD2T1AB3VVWT0QL0"

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <RestKit.h>
#import "BubbleTeaStore.h"
#import "Location.h"
#import "Contact.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    // Set up RestKit
    [self configureRestKit];
    [self loadStores];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
}

# pragma mark - Lazy Instantiation

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

#pragma mark - RestKit

- (void)configureRestKit {
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup nested object mappings within BubbleTeaStore
    // location
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    // contact
    RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[Contact class]];
    [contactMapping addAttributeMappingsFromArray:@[@"formattedPhone", @"twitter", @"facebookName"]];
    // set up overall BubbleTeaStore mapping
    RKObjectMapping *storeMapping = [RKObjectMapping mappingForClass:[BubbleTeaStore class]];
    [storeMapping addAttributeMappingsFromArray:@[@"name"]];
    //[storeMapping addPropertyMappingsFromArray:@[locationMapping, contactMapping]];
    [storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location"
                                                                                   toKeyPath:@"location"
                                                                                 withMapping:locationMapping]];
    [storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact"
                                                                                 toKeyPath:@"contact"
                                                                               withMapping:contactMapping]];
    
    
    
    //RKObjectMapping *storeMapping = [RKObjectMapping mappingForClass:[BubbleTeaStore class]];
    //[storeMapping addAttributeMappingsFromArray:@[@"name"]];
    
//    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
//    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    //[storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    
    //RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[Contact class]];
    //[contactMapping addAttributeMappingsFromArray:@[@"twitter"]];
    //[storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact" toKeyPath:@"contact" withMapping:contactMapping]];
    
    
    /*RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[Contact class]];
    [contactMapping addAttributeMappingsFromArray:@[@"formattedPhone", @"twitter", @"facebookName"]];
    [storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact" toKeyPath:@"contact" withMapping:contactMapping]];*/

    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:storeMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

- (void)loadStores {
    NSString *latLon = @"37.33,-122.03"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : CLIENTID,
                                  @"client_secret" : CLIENTSECRET,
                                  @"categoryId" : @"52e81612bcbc57f1066b7a0c",
                                  @"v" : @"20140806"
                                  };
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.stores = mappingResult.array;
                                                  [self printStoreInfo];
                                                  //refresh on map
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no boba here?!': %@", error);
                                              }];
}

#pragma mark - Debug

- (void)printStoreInfo {
    for (BubbleTeaStore *store in self.stores) {
        NSLog(@"Name: %@", store.name);
        //NSLog(@"Description: %@", store.description);
        NSLog(@"Phone #: %@", store.contact.formattedPhone);
        NSLog(@"Twitter: %@", store.contact.twitter);
        NSLog(@"Facebook: %@", store.contact.facebookName);
        NSLog(@"Address: %@ %@, %@, %@, %@", store.location.address, store.location.city, store.location.state, store.location.country, store.location.postalCode);
        NSLog(@"Distance: %@", store.location.distance);
        NSLog(@"Coordinates: (%@, %@)", store.location.lat, store.location.lng);
        NSLog(@"====================================");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
