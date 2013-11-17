//
//  sportzteamsPlayerInfoViewController.m
//  smpwlions
//
//  Created by Gilbert Zaldivar on 3/27/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PlayerInfoViewController.h"
#import "sportzServerInit.h"
#import "EazesportzAppDelegate.h"
//#import "sportzteamsGameScheduleJSON.h"
#import "EazeSoccerStatsViewController.h"
#import "EazeAlertViewController.h"
#import "EazePhotosViewController.h"
#import "EazesVideosViewController.h"
#import "EazeBasketballStatsViewController.h"

@interface PlayerInfoViewController () {
    NSArray *serverData;
    NSMutableData *theData;
    int responseStatusCode;
    
    BOOL follow;
    BOOL unfollow;
}

@end

@implementation PlayerInfoViewController

@synthesize player;

@synthesize playerImage;
@synthesize numberLabel;
@synthesize nameLabel;
@synthesize yearLabel;
@synthesize heightLabel;
@synthesize weightLabel;
@synthesize positionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.photoButton, self.videoButton, self.alertButton, self.statsButton, nil];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    playerImage.image = [player getImage:@"thumb"];
    [self.numberLabel setText:[player.number stringValue]];
    [self.nameLabel setText:player.full_name];
    [self.yearLabel setText:player.year];
    [self.positionLabel setText:player.position];
    [self.heightLabel setText:player.height];
    [self.weightLabel setText:[player.weight stringValue]];
    _bioTextView.text = player.bio;
    
    if ([currentSettings hasAlerts:[player athleteid]] == NO) {
        _alertButton.enabled = NO;
    }
    
    if ([player.following boolValue]) {
        [_followSwitch setOn:YES];
    } else {
        [_followSwitch setOn:NO];
    }
    
    if (!player.hasphotos) {
        _photoButton.enabled = NO;
    }
    
    if (!player.hasvideos) {
        _videoButton.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlayerStatsSegue"]) {
        EazeSoccerStatsViewController *destViewController = segue.destinationViewController;
        destViewController.athlete = player;
    } else if ([segue.identifier isEqualToString:@"AlertListSegue"]) {
        EazeAlertViewController *destViewController = segue.destinationViewController;
        destViewController.player = player;
    } else if ([segue.identifier isEqualToString:@"PlayerPhotosSegue"] ) {
        EazePhotosViewController *destController = segue.destinationViewController;
        destController.player = player;
    } else if ([segue.identifier isEqualToString:@"PlayerVideosSegue"]) {
        EazesVideosViewController *destController = segue.destinationViewController;
        destController.player = player;
    } else if ([segue.identifier isEqualToString:@"BasketballPlayerStatsSegue"]) {
        EazeBasketballStatsViewController *destController = segue.destinationViewController;
        destController.athlete = player;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    _bannerView.hidden = NO;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    _bannerView.hidden = YES;
}

- (IBAction)followPlayerSwitch:(id)sender {
    if ([_followSwitch isOn]) {
        follow = YES;
        NSURL *url = [NSURL URLWithString:[sportzServerInit followAthlete:[player athleteid] Token:currentSettings.user.authtoken]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    } else {
        unfollow = YES;
        NSURL *url = [NSURL URLWithString:[sportzServerInit unfollowAthlete:[player athleteid] Token:currentSettings.user.authtoken]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = [httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The download cound not complete - please make sure you're connected to either 3G or WI-FI" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [errorView show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    serverData = [NSJSONSerialization JSONObjectWithData:theData options:nil error:nil];
    NSLog(@"%@", serverData);
    
    if (responseStatusCode == 200) {
        UIAlertView *alert;
        if (follow) {
            follow = NO;
            player.following = [NSNumber numberWithBool:YES];
            alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                         message:[NSString stringWithFormat:@"%@%@", @"Now following: ", [player name]]
                                         delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        } else if (unfollow) {
            unfollow = NO;
            player.following = [NSNumber numberWithBool:NO];
            alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                         message:[NSString stringWithFormat:@"%@%@", @"Stopped following: ", [player name]]
                                         delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        }
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        [self viewWillAppear:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Alerts"
                                                        message:[NSString stringWithFormat:@"%d", responseStatusCode]
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

- (IBAction)playerStatsButtonClicked:(id)sender {
    if (currentSettings.user.isBasic) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upgrade for Stats" message:@"Click settings to upgrade for player stats!"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    }
        
}

- (IBAction)alertButtonClicked:(id)sender {
    if (currentSettings.user.isBasic) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upgrade for Alerts" message:@"Click settings to upgrade for player alerts!"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"AlertListSegue" sender:self];
    }
}

@end
