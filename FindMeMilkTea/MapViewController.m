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
#import "StoreDetailViewController.h"
#import "PreferenceBanner.h"
#import "HUD.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet PreferenceBanner *banner;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (nonatomic) NSUInteger userChoice;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.banner.hidden = YES;
    self.bottomBar.hidden = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBanner {
    if (self.userChoice < self.stores.count) {
        self.banner.frame = CGRectMake(0, -100, self.view.frame.size.width, 100);
        self.banner.preferredStore = [self closestStoreAt:self.userChoice];
        [UIView animateWithDuration:0.5 animations:^{
            self.banner.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        }];
    }
}

- (void)tapBanner:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"store-details" sender:self];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D startLoc = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(startLoc, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    [self configureRestKit];
    [self loadStores];
}

- (void)setInitialMapRegion {
    MKCoordinateRegion region;
    CLLocationCoordinate2D userLocation = self.mapView.userLocation.coordinate;
    
    float minLat = userLocation.latitude;
    float minLng = userLocation.longitude;
    float maxLat = userLocation.latitude;
    float maxLng = userLocation.longitude;
    
    for (int i = 0; i < 4; i++) {
        BubbleTeaStore *store = [self.stores objectAtIndex:i];
        if (store.location.lat.floatValue < minLat) {
            minLat = store.location.lat.floatValue;
        }
        if (store.location.lng.floatValue < minLng) {
            minLng = store.location.lng.floatValue;
        }
        if (store.location.lat.floatValue > maxLat) {
            maxLat = store.location.lat.floatValue;
        }
        if (store.location.lng.floatValue > maxLng) {
            maxLng = store.location.lng.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 2.1f;
    region.span.longitudeDelta = (maxLng - minLng) * 2.1f;
    
    [self.mapView setRegion:region animated:YES];
}

- (void)setNewMapRegion {
    if (self.userChoice >= self.stores.count) {
        self.userChoice = 0;
    }
    MKCoordinateRegion region;
    BubbleTeaStore *store = [self.stores objectAtIndex:self.userChoice];
    region.center.latitude = store.location.lat.floatValue;
    region.center.longitude = store.location.lng.floatValue;
    region.span.latitudeDelta = fabs(region.center.latitude - self.mapView.userLocation.coordinate.latitude) / 2.2f;
    region.span.longitudeDelta = fabs(region.center.longitude - self.mapView.userLocation.coordinate.longitude) / 2.2f;
    [self.mapView setRegion:region animated:YES];
}

# pragma mark - Lazy Instantiation

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

#pragma mark - MapKit

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //check annotation is not user location
    if([annotation isEqual:[mapView userLocation]])
    {
        //bail
        return nil;
    }
    static NSString* reuseId = @"BubbleTeaStore";
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.image = [UIImage imageNamed:@"boba5"];
        view.canShowCallout = YES;
        
        // create a button as a right callout accessories
        // once this button is clicked, a segue is performed to show corresponding info
        UIButton* disclosureButton = [[UIButton alloc] init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.rightCalloutAccessoryView = disclosureButton;
    } else {
        view.annotation = annotation;
    }
    return view;
}

// Once a pin MKAnnotation is clicked/selected
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [UIView animateWithDuration:0.3 animations:^{
        view.image = [UIImage imageNamed:@"boba5-large"];
    }];
}

// Once a pin MKAnnotation is unselected
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [UIView animateWithDuration:0.3 animations:^{
        view.image = [UIImage imageNamed:@"boba5"];
    }];
}

- (BubbleTeaStore *)closestStoreAt: (NSUInteger)index {
    return self.stores ? [self.stores objectAtIndex:index] : nil;
}

- (NSArray *)sortStores {
    return self.stores ? [self.stores sortedArrayUsingSelector:@selector(compare:)] : nil;
}

- (IBAction)findPrevClosest:(id)sender {
    if (self.userChoice > 0) {
        self.userChoice--;
        [self setNewMapRegion];
        [self hilightAnnotationAtIndex:self.userChoice];
        [self setupBanner];
    } else {
        self.userChoice = self.stores.count - 1;
    }
}

- (IBAction)findNextClosest:(id)sender {
    if (self.userChoice < [self.stores count]) {
        self.userChoice++;
        [self setNewMapRegion];
        [self hilightAnnotationAtIndex:self.userChoice];
        [self setupBanner];
    } else {
        self.userChoice = 0;
    }
}

- (void)hilightAnnotationAtIndex:(NSUInteger)index {
    if (index < self.stores.count) {
        BubbleTeaStore *store = [self.stores objectAtIndex:self.userChoice];
        for (id<MKAnnotation> annotation in self.mapView.annotations){
            MKAnnotationView* anView = [self.mapView viewForAnnotation:annotation];
            if (anView.annotation.coordinate.latitude == store.location.lat.floatValue && anView.annotation.coordinate.longitude == store.location.lng.floatValue){
                // hilight next annotation that shows on banner
                [UIView animateWithDuration:0.3 animations:^{
                    for (id<MKAnnotation> annotation in self.mapView.annotations){
                        if ([annotation isKindOfClass:[MKUserLocation class]]) {
                            continue;
                        }
                        MKAnnotationView *prevHilighted = [self.mapView viewForAnnotation:annotation];
                        prevHilighted.image = [UIImage imageNamed:@"boba5"];
                        [self.mapView deselectAnnotation:annotation animated:YES];
                    }
                    anView.image = [UIImage imageNamed:@"boba5-large"];
                    [self.mapView selectAnnotation:anView.annotation animated:YES];
                }];
            }
        }
    } else {
        self.userChoice = 0;
    }
}

#pragma mark - RestKit

- (void)configureRestKit {
    // start spinner
    [HUD showUIBlockingIndicatorWithText:@"Searching..."];
    
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
    [contactMapping addAttributeMappingsFromDictionary:@{ @"phone" : @"formattedPhone",
                                                        @"twitter" : @"twitter",
                                                        @"facebookName" : @"facebookName" }];
    
    // set up overall BubbleTeaStore mapping
    RKObjectMapping *storeMapping = [RKObjectMapping mappingForClass:[BubbleTeaStore class]];
    [storeMapping addAttributeMappingsFromDictionary:@{ @"name" : @"title",
                                                        @"menu.url" : @"menuURL"}];
    [storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location"
                                                                                   toKeyPath:@"location"
                                                                                 withMapping:locationMapping]];
    [storeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact"
                                                                                 toKeyPath:@"contact"
                                                                               withMapping:contactMapping]];

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
    if (self.mapView.userLocation.location) {
        NSString *latLon = [NSString stringWithFormat:@"%f,%f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude];
        
        NSDictionary *queryParams = @{@"ll" : latLon,
                                      @"client_id" : CLIENTID,
                                      @"client_secret" : CLIENTSECRET,
                                      @"categoryId" : @"52e81612bcbc57f1066b7a0c",
                                      @"v" : @"20140806",
                                      @"limit" : @"200"
                                      };
        
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                                   parameters:queryParams
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          if ([mappingResult count]) {
                                                              self.stores = mappingResult.array;
                                                              self.stores = [self sortStores];
                                                              [self printStoreInfo];
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  //refresh on map
                                                                  [self setInitialMapRegion];
                                                                  [self.mapView addAnnotations:self.stores];
                                                                  [HUD hideUIBlockingIndicator];
                                                                  
                                                                  // set up top/bottom banners
                                                                  [self setupBanner];
                                                                  UITapGestureRecognizer *singleFingerTap =
                                                                  [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(tapBanner:)];
                                                                  [self.banner addGestureRecognizer:singleFingerTap];
                                                                  self.banner.hidden = NO;
                                                                  
                                                                  self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height + 20, self.view.frame.size.width, 40);
                                                                  [UIView animateWithDuration:0.3 animations:^{
                                                                      self.bottomBar.hidden = NO;
                                                                      self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40);
                                                                  }];
                                                              });
                                                          }
                                                          else {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry there are no bubble tea stores detected nearby."
                                                                                                              message:@""
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"OK"
                                                                                                    otherButtonTitles:nil];
                                                              [alert show];
                                                              [self.locationManager stopUpdatingLocation];
                                                              return;
                                                          }
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          NSLog(@"What do you mean by 'there is no boba here?!': %@", error);
                                                      }];
        });
        [self.locationManager stopUpdatingLocation];
    }
    else {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Debug

- (void)printStoreInfo {
    for (BubbleTeaStore *store in self.stores) {
        NSLog(@"Name: %@", store.title);
        NSLog(@"Phone #: %@", store.contact.formattedPhone);
        NSLog(@"Twitter: %@", store.contact.twitter);
        NSLog(@"Facebook: %@", store.contact.facebookName);
        NSLog(@"Address: %@", store.subtitle);
        NSLog(@"Menu: %@", store.menuURL);
        NSLog(@"Distance: %@", store.location.distance);
        NSLog(@"Coordinates: (%@, %@)", store.location.lat, store.location.lng);
        NSLog(@"====================================");
    }
}


#pragma mark - Navigation

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[BubbleTeaStore class]])
        [self performSegueWithIdentifier:@"store-details" sender:view];
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        if ([segue.destinationViewController isKindOfClass:[StoreDetailViewController class]]) {
            id <MKAnnotation> annotation = ((MKAnnotationView*)sender).annotation;
            if ([annotation isKindOfClass:[BubbleTeaStore class]]) {
                BubbleTeaStore* store = (BubbleTeaStore*)annotation;
                if (store) {
                    if ([segue.identifier isEqualToString:@"store-details"]){
                        StoreDetailViewController *sdvc = segue.destinationViewController;
                        sdvc.store = store;
                    }
                }
            }
        }
    }
    else if ([sender isKindOfClass:[MapViewController class]]) {
        if ([segue.identifier isEqualToString:@"store-details"]){
            StoreDetailViewController *sdvc = segue.destinationViewController;
            sdvc.store = [self.stores objectAtIndex:self.userChoice];
            [self setNewMapRegion];
            [self hilightAnnotationAtIndex:self.userChoice];
        }
    }
}


@end
