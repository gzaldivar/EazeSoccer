//
//  sportzteamsAlertViewController.m
//  smpwlions
//
//  Created by Gilbert Zaldivar on 5/2/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EazeAlertViewController.h"
#import "EazesportzAppDelegate.h"
#import "sportzCurrentSettings.h"
#import "sportzServerInit.h"
#import "Alert.h"
//#import "sportzteamsBlogViewController.h"
#import "EazeSoccerPlayerStatsViewController.h"
//#import "sportzteamsPhotoInfoViewController.h"
//#import "sportzteamsMovieViewController.h"
//#import "sportzteamsAlertsJSON.h"

@interface EazeAlertViewController () <UIAlertViewDelegate>
@end

@implementation EazeAlertViewController {
    NSString *playerName;

    NSArray *serverData;
    NSMutableData *theData;
    int responseStatusCode;

    BOOL getalerts;
    BOOL clearalerts;
    NSString *displayed_alerts;
}

@synthesize player;
@synthesize alerts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alerts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    _playerNameLabel.layer.cornerRadius = 4;
    getalerts = NO;
    displayed_alerts = @"All";
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.searchButton, self.clearButton, nil];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    if (player != nil) {
        _playerImage.image = [player getImage:@"thumb"];
    }
    [_playerNameLabel setText:player.full_name];
    alerts = [currentSettings findAlerts:player.athleteid];
    [_alertTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [_alertTableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"AlertBlogSegue"]) {
//        sportzteamsBlogViewController *destViewController = segue.destinationViewController;
//        destViewController.blogPlayer = player;
    } else if ([segue.identifier isEqualToString:@"AthleteAlertStatsSegue"]) {
        EazeSoccerPlayerStatsViewController *destViewController = segue.destinationViewController;
        destViewController.player = player;
        Soccer *stats = [player findSoccerStats:[[alerts objectAtIndex:indexPath.row] stat]];
        destViewController.game = [currentSettings findGame:stats.gameschedule_id];
    } else if ([segue.identifier isEqualToString:@"AlertPhotoSegue"]) {
//        sportzteamsPhotoInfoViewController *destViewController = segue.destinationViewController;
//        destViewController.photoid = [[alerts objectAtIndex:indexPath.row] photo];
    } else if ([segue.identifier isEqualToString:@"VideoclipAlertSegue"]) {
//        sportzteamsMovieViewController *destViewController = segue.destinationViewController;
//        destViewController.videoid = [[alerts objectAtIndex:indexPath.row] videoclip];
    }
}

- (IBAction)sortButtonClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sort Alerts" message:nil delegate:self cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Blog", @"Stats", @"Photo", @"Video", @"Bio", @"All", nil];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[sportzServerInit getAlerts:currentSettings.user.userid Token:currentSettings.user.authtoken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)clearButtonClicked:(id)sender {
    clearalerts = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:[sportzServerInit clearAlerts:[player athleteid] AlertType:displayed_alerts
                 Token:currentSettings.user.authtoken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = [httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The download cound not complete - please make sure you're connected to either 3G or WI-FI" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [errorView show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
    NSLog(@"%@", serverData);
    
    if (responseStatusCode == 200) {
        if (clearalerts) {
            clearalerts = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Successful"
                                                            message:[NSString stringWithFormat:@"%@,%@", displayed_alerts, @" Alerts removed from athlete!"]
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
            
            for (int i = 0; i < [alerts count]; i++) {
                Alert *anAlert = [alerts objectAtIndex:i];
                [currentSettings deleteAlert:anAlert];
            }
            
            alerts = [[NSMutableArray alloc] init];
            [_alertTableView reloadData];
        } else {
            currentSettings.alerts = [[NSMutableArray alloc] init];
            for (int i = 0; i < serverData.count; i++) {
                [currentSettings.alerts addObject:[[Alert alloc] initWithDirectory:[serverData objectAtIndex:i]]];
            }
            alerts = [currentSettings findAlerts:player.athleteid];
            [_alertTableView reloadData];
            
            if (alerts.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Alerts for" message:player.logname
                                                               delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Alert"
                                                        message:[NSString stringWithFormat:@"%d", responseStatusCode]
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSMutableArray *alertlist = [[NSMutableArray alloc] init];
    alerts = [currentSettings findAlerts:player.athleteid];
    
    if([title isEqualToString:@"All"]) {
        getalerts = YES;
        displayed_alerts = @"All";
    } else {
        
        for (int i = 0; i < [alerts count]; i++) {
            if (([title isEqualToString:@"Blog"]) && ([[[alerts objectAtIndex:i] blog] length] > 0)) {
                displayed_alerts = @"Blog";
                [alertlist addObject:[alerts objectAtIndex:i]];
            } else if (([title isEqualToString:@"Stats"]) && ([[[alerts objectAtIndex:i] stat] length] > 0)) {
                displayed_alerts = @"Stats";
                [alertlist addObject:[alerts objectAtIndex:i]];
            } else if (([title isEqualToString:@"Photo"]) && ([[[alerts objectAtIndex:i] photo] length] > 0)) {
                displayed_alerts = @"Photo";
                [alertlist addObject:[alerts objectAtIndex:i]];
            } else if (([title isEqualToString:@"Video"]) && ([[[alerts objectAtIndex:i] videoclip] length] > 0)) {
                displayed_alerts = @"Video";
                [alertlist addObject:[alerts objectAtIndex:i]];
            } else if (([title isEqualToString:@"Bio"]) && ([[[alerts objectAtIndex:i] stat] length] == 0) &&
                       ([[[alerts objectAtIndex:i] photo] length] == 0) && ([[[alerts objectAtIndex:i] videoclip] length] == 0) &&
                       ([[[alerts objectAtIndex:i] blog] length] == 0)) {
                displayed_alerts = @"Bio";
                [alertlist addObject:[alerts objectAtIndex:i]];
            }
        }
        alerts = alertlist;
    }
    [_alertTableView reloadData];
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
    return alerts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlertTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    Alert *alert = [alerts objectAtIndex:indexPath.row];
    cell.textLabel.text = alert.message;
    cell.detailTextLabel.text = alert.created_at;
    
    if ([[alert blog] length] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"blog.png"]];
    } else if ([[alert photo] length] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"camera-photo-button.png"]];
    } else if ([[alert videoclip] length] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"play-button.png"]];
    } else if ([[alert stat] length] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"statistics-button.png"]];
    } else if ([[alert athlete] length] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:@"biobutton.png"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Select Item
    if ([[[alerts objectAtIndex:indexPath.row] blog] length] > 0) {
        [self performSegueWithIdentifier: @"AlertBlogSegue" sender: self];
    } else if ([[[alerts objectAtIndex:indexPath.row] stat] length] > 0) {
        [self performSegueWithIdentifier: @"AthleteAlertStatsSegue" sender: self];
    } else if ([[[alerts objectAtIndex:indexPath.row] photo] length] > 0) {
        [self performSegueWithIdentifier: @"AlertPhotoSegue" sender: self];
    } else if ([[[alerts objectAtIndex:indexPath.row] videoclip] length] > 0) {
        [self performSegueWithIdentifier:@"VideoclipAlertSegue" sender:self];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@%@", @"Alerts for ", player.logname];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source
         
         if (![[alerts objectAtIndex:indexPath.row] initDeleteAlert]) {
             [alerts removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }  else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[alerts objectAtIndex:indexPath.row] httperror]
                                                            delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             [alert setAlertViewStyle:UIAlertViewStyleDefault];
             [alert show];
         }
     }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }

@end