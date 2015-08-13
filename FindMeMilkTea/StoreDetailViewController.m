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
#import "OAMutableURLRequest.h"
#import "WebPageViewController.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";

@interface StoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIMG;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UILabel *twitterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIMG;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIMG;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;
@property (weak, nonatomic) IBOutlet UIImageView *addressIMG;
@property (weak, nonatomic) IBOutlet UILabel *menuLabel;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIImageView *menuIMG;
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
    self.navBar.topItem.title = [NSString stringWithString:self.store.title];
    
    int missing = 0;
    
    if ([self.store.location.address isEqualToString:@""] || !self.store.location.address) {
        self.addressLabel.hidden = YES;
        self.addressIMG.hidden = YES;
        self.getDirectionsButton.hidden = YES;
        missing++;
    } else {
        self.addressLabel.text = [NSString stringWithString:self.store.subtitle];
    }
    
    if (self.store.contact.formattedPhone) {
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.store.contact.formattedPhone
                                                                         attributes:underlineAttribute];
    } else {
        self.phoneLabel.hidden = YES;
        self.phoneIMG.hidden = YES;
        self.callButton.hidden = YES;
        missing++;
    }
    
    if (self.store.contact.twitter) {
        self.twitterLabel.text = [NSString stringWithFormat:@"@%@", self.store.contact.twitter];
    } else {
        self.twitterLabel.hidden = YES;
        self.twitterIMG.hidden = YES;
        missing++;
    }
    
    if (self.store.contact.facebookName) {
        self.facebookLabel.text = [NSString stringWithString:self.store.contact.facebookName];
    } else {
        self.facebookLabel.hidden = YES;
        self.facebookIMG.hidden = YES;
        missing++;
    }
    
    if (self.store.menuURL) {
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        self.menuLabel.attributedText = [[NSAttributedString alloc] initWithString:self.store.menuURL
                attributes:underlineAttribute];
    } else {
        self.menuLabel.hidden = YES;
        self.menuIMG.hidden = YES;
        self.menuButton.hidden = YES;
        missing++;
    }
    
    if (missing == 5) {
        UILabel *noneAvail = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 25, self.view.frame.size.width, 50)];
        noneAvail.text = @"Information not available.";
        noneAvail.textAlignment = NSTextAlignmentCenter;
        noneAvail.font = [UIFont fontWithName:@"Arial" size:20];
        [self.view addSubview:noneAvail];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)callStore:(id)sender {
    NSLog(@"call");
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", self.store.contact.formattedPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
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

- (IBAction)visitWebsite:(id)sender {
}

/*
static NSString * const kConsumerKey       = @"HBiL_y0xMIOBxLAgi3wcrw";
static NSString * const kConsumerSecret    = @"AFZlFtGEi1hANs7PI87Lxy75nW0";
static NSString * const kToken             = @"yuCx01jUPD9AIFnIYSQbZNy7l6knVnWV";
static NSString * const kTokenSecret       = @"iGVl08YSKl-sckXf1eXFi67r5LA";

- (void)fetchYelp{
    NSString *rootYelpURL = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=food&location=San%20Francisco"];//, self.store.location.lat, self.store.location.lng];
    
    //NSURL *URL = [NSURL URLWithString:rootYelpURL];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey secret:kConsumerSecret];
    OAToken *token = [[OAToken alloc] initWithKey:kToken secret:kTokenSecret];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init] ;
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];

    NSURLSessionTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",json);
    }];
    
    [task resume];
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"show-menu"] && [segue.destinationViewController isKindOfClass:[WebPageViewController class]]) {
        WebPageViewController *wpvc = segue.destinationViewController;
        wpvc.menuURL = self.store.menuURL;
        wpvc.title = self.store.title;
    }
}


@end
