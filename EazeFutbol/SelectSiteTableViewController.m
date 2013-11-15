//
//  SelectSiteTableViewController.m
//  Eazebasketball
//
//  Created by Gil on 9/30/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "SelectSiteTableViewController.h"
#import "EazesportzAppDelegate.h"
#import "sportzServerInit.h"
#import "sportzteamsRegisterLoginViewController.h"

@interface SelectSiteTableViewController () <UIAlertViewDelegate>

@end

@implementation SelectSiteTableViewController {
    NSMutableArray *siteList;
    
    Sport *sport;
}

@synthesize state;
@synthesize sitename;
@synthesize city;
@synthesize zipcode;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ((state.length > 0) || (zipcode.length > 0) || (city.length > 0) || (sitename.length > 0)) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *url = [NSURL URLWithString:[sportzServerInit getSiteList:state Zip:zipcode City:city SiteName:sitename
                                                              Sportname:[mainBundle objectForInfoDictionaryKey:@"sportzteams"]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse* response;
        NSError *error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        if ([(NSHTTPURLResponse*)response statusCode] == 200) {
            NSArray *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
            siteList = [[NSMutableArray alloc] init];
            for (int i = 0; i < [serverData count]; i++) {
                Sport *asport = [[Sport alloc] initWithDictionary:[serverData objectAtIndex:i]];
                 
                if ((asport.approved) && ([asport.teamcount intValue] > 0))
                    [siteList addObject:asport];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Retrieving Site List" delegate:nil
                                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
    }
    [_siteTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return siteList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SiteTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Sport *asport = [siteList objectAtIndex:indexPath.row];
    cell.textLabel.text = asport.sitename;
    cell.imageView.image = [asport getImage:@"tiny"];
    cell.detailTextLabel.text = asport.mascot;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    sport = [siteList objectAtIndex:indexPath.row];
    if (currentSettings.user.email.length > 0) {
        NSURL *url = [NSURL URLWithString:[sportzServerInit changeDefaultSite:[sport id] Token:currentSettings.user.authtoken]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse* response;
        NSError *error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        NSDictionary *newsite = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        NSDictionary *sportdata = [newsite objectForKey:@"site"];
        currentSettings.sport.id = [sportdata objectForKey:@"_id"];
        [currentSettings retrieveSport];
        currentSettings.team = nil;;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                        message:@"Change Site Successful"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        [self performSegueWithIdentifier:@"RegisterSiteLoginSegue" sender:self];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Sites";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [_siteTableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"RegisterSiteLoginSegue"]) {
        sportzteamsRegisterLoginViewController *destController = segue.destinationViewController;
        destController.sport = [siteList objectAtIndex:indexPath.row];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    UITabBarController *tabBarController = self.tabBarController;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:0] view];
    
    if ([title isEqualToString:@"Ok"]) {
        // Transition using a page curl.
        [UIView transitionFromView:fromView toView:toView duration:0.5
                           options:(4 > tabBarController.selectedIndex ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown)
                        completion:^(BOOL finished) {
                            if (finished) {
                                tabBarController.selectedIndex = 0;
                            }
                        }];
        
    }
}

@end
