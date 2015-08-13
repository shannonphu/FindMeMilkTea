//
//  WebPageViewController.m
//  FindMeMilkTea
//
//  Created by Shannon Phu on 8/13/15.
//  Copyright (c) 2015 Shannon Phu. All rights reserved.
//

#import "WebPageViewController.h"

@interface WebPageViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation WebPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navBar.topItem.title = [NSString stringWithString:self.title];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.menuURL]];
    [self.webView loadRequest:request];
}

- (IBAction)return:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
