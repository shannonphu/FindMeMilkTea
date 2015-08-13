//
//  StoreDetailViewController.m
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/11/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "BubbleTeaStore.h"
#import "Contact.h"
#import "Location.h"
#import <MapKit/MapKit.h>

@interface StoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIMG;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIMG;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIMG;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addressIMG;
@end

@implementation StoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}

- (void)viewWillAppear:(BOOL)animated {
    self.titleLabel.text = [NSString stringWithString:self.store.title];
    if (self.store.contact.formattedPhone) {
        self.phoneLabel.text = [NSString stringWithString:self.store.contact.formattedPhone];
    } else {
        self.phoneLabel.hidden = YES;
        self.phoneIMG.hidden = YES;
    }
    if (self.store.contact.twitter) {
        self.twitterLabel.text = [NSString stringWithFormat:@"@%@", self.store.contact.twitter];
    } else {
        self.twitterLabel.hidden = YES;
        self.twitterIMG.hidden = YES;
    }
    if (self.store.contact.facebookName) {
        self.facebookLabel.text = [NSString stringWithString:self.store.contact.facebookName];
    } else {
        self.facebookLabel.hidden = YES;
        self.facebookIMG.hidden = YES;
    }
    self.addressLabel.text = [NSString stringWithString:self.store.subtitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)getDirections:(id)sender {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.store.location.lat.floatValue, self.store.location.lng.floatValue);
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = [NSString stringWithString:self.store.title];
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
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
