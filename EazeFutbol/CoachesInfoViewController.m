//
//  sportzteamsCoachesInfoViewController.m
//  smpwlions
//
//  Created by Gilbert Zaldivar on 4/2/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "CoachesInfoViewController.h"

#import <QuartzCore/QuartzCore.h>


@interface CoachesInfoViewController ()

@end

@implementation CoachesInfoViewController

@synthesize coach;
@synthesize years;
@synthesize staffPosition;
@synthesize coachImage;
@synthesize nameLabel;
@synthesize bioTextVeiw;

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
    self.years.layer.cornerRadius = 4;
    nameLabel.layer.cornerRadius = 4;
    nameLabel.numberOfLines = 2;
    bioTextVeiw.editable = NO;
    bioTextVeiw.layer.cornerRadius = 4;
    self.staffPosition.layer.cornerRadius = 4;
    staffPosition.numberOfLines = 2;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [nameLabel setText:coach.fullname];
    [years setText:[coach.years stringValue]];
    [bioTextVeiw setText:coach.bio];
    self.title = coach.fullname;
    [staffPosition setText:coach.speciality];
    coachImage.image = [coach getImage:@"thumb"];
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

@end