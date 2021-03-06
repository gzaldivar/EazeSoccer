 //
//  PhotoInfoViewController.m
//  FootballStatsConsole
//
//  Created by Gilbert Zaldivar on 7/1/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "PhotoInfoViewController.h"
#import "EazesportzAppDelegate.h"
#import "sportzCurrentSettings.h"
#import "sportzServerInit.h"

#import "Athlete.h"
#import "EditPlayerViewController.h"
#import "EditUserViewController.h"
#import "PlayerSelectionViewController.h"
#import "EditGameViewController.h"
#import "EditTeamViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoInfoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, AmazonServiceRequestDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation PhotoInfoViewController {
    PlayerSelectionViewController *playerSelectController;
    
    BOOL newPhoto, newmedia, imageselected;
    int imagesize;
    NSString *imagepath;
    NSData *imgData;
    
    UITextView *activeField;
    User *user;
    
    NSMutableArray *addtags, *removetags;
}

@synthesize photo;
@synthesize popover;
@synthesize gameController;
@synthesize scrollView;

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
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"])
        self.view.backgroundColor = [UIColor whiteColor];
    else
        self.view.backgroundColor = [UIColor whiteColor];
    
    [_photoImage setClipsToBounds:YES];
    
    _gameTextField.inputView = gameController.inputView;
    _cameraButton.layer.cornerRadius = 4;
    _cameraRollButton.layer.cornerRadius = 4;
    _gameButton.layer.cornerRadius = 4;
    _teamButton.layer.cornerRadius = 4;
    _deleteButton.layer.cornerRadius = 4;
    _descriptionTextView.layer.cornerRadius = 4;
    _playerTableView.layer.borderWidth = 1.0f;
    _playerTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _descriptionTextView.layer.borderWidth = 1.0f;
    _descriptionTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    _activityIndicator.hidesWhenStopped = YES;
    newPhoto = NO;
    
    [self registerForKeyboardNotifications];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.saveBarButton, self.deleteBarButton, self.cameraBarButton,
                                              self.cameraRollBarButton, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    addtags = [[NSMutableArray alloc] init];
    removetags = [[NSMutableArray alloc] init];
    
    if ((photo) && (!newPhoto)) {
        if (currentSettings.sport.review_media) {
            [_approvalSwitch setOn:photo.pending];
            _approvalSwitch.hidden = NO;
            _approvalSwitch.enabled = YES;
        }
        
        newPhoto = NO;
        _cameraRollButton.hidden = YES;
        _cameraRollButton.enabled = NO;
        _cameraButton.hidden = YES;
        _cameraButton.enabled = NO;
        
        if (photo.medium_url.length > 0) {
            NSURL * imageURL = [NSURL URLWithString:photo.medium_url];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            
            if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"]) {
                _photoImage.image = [UIImage imageWithData:imageData];
                CGSize imageviewsize;
                
                if (_photoImage.image.size.width > _photoImage.image.size.height)
                    imageviewsize = CGSizeMake(700.0, 525.0);
                else
                    imageviewsize = CGSizeMake(525.0, 700.0);
                
                _photoImage.frame = CGRectMake(_photoImage.frame.origin.x,_photoImage.frame.origin.y, imageviewsize.width, imageviewsize.height);
            } else
                _photoImage.image = [currentSettings normalizedImage:[UIImage imageWithData:imageData] scaledToSize:200];
        } else {
            _photoImage.image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageNamed:@"photo_processing.png"], 1)];
        }
        
        _descriptionTextView.text = photo.description;
        _photonameTextField.text = photo.displayname;
        
        NSURL *url = [NSURL URLWithString:[sportzServerInit getAUser:photo.owner Token:currentSettings.user.authtoken]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse* response;
        NSError *error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        int responseStatusCode = [(NSHTTPURLResponse*)response statusCode];
        NSDictionary *userdata = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        
        if (responseStatusCode == 200) {
            user = [[User alloc] init];
            user.userid = [userdata objectForKey:@"id"];
            user.username = [userdata objectForKey:@"name"];
            user.email = [userdata objectForKey:@"email"];
            user.authtoken = [userdata objectForKey:@"authentication_token"];
            user.userthumb = [userdata objectForKey:@"avatar"];
            user.tiny = [userdata objectForKey:@"tiny"];
            user.isactive = [NSNumber numberWithInteger:[[userdata objectForKey:@"is_active"] integerValue]];
            user.bio_alert = [NSNumber numberWithInteger:[[userdata objectForKey:@"bio_alert"] integerValue]];
            user.blog_alert = [NSNumber numberWithInteger:[[userdata objectForKey:@"blog_alert"] integerValue]];
            user.media_alert = [NSNumber numberWithInteger:[[userdata objectForKey:@"media_alert"] integerValue]];
            user.stat_alert = [NSNumber numberWithInteger:[[userdata objectForKey:@"stat_alert"] integerValue]];
            user.score_alert = [NSNumber numberWithInteger:[[userdata objectForKey:@"score_alert"] integerValue]];
            user.admin = [[userdata objectForKey:@"admin"] boolValue];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem Retrieving User"
                                                            message:[NSString stringWithFormat:@"%d", responseStatusCode]
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
        
        if (photo.schedule.length > 0) {
            photo.game = [currentSettings retrieveGame:photo.schedule];
            _gameTextField.text = [photo.game vsOpponent];
        } else {
            _gameButton.enabled = NO;
            [_gameButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        
        if ([currentSettings.teamPhotos isFeaturedPhoto:photo])
            [_featuredSwitch setOn:YES];
        else
            [_featuredSwitch setOn:NO];
        
        if (photo.pending) {
            _pendingLabel.text = @"Pending";
            [_approvalSwitch setOn:NO];
        } else {
            _pendingLabel.text = @"Approved";
            [_approvalSwitch setOn:YES];
        }
        
        if (([currentSettings isSiteOwner]) && (currentSettings.sport.review_media)) {
            _pendingLabel.hidden = NO;
            _approvalSwitch.hidden = NO;
            _approvalSwitch.enabled = YES;
        } else {
            _approvalSwitch.hidden = YES;
            _pendingLabel.hidden = YES;
            _approvalSwitch.enabled = NO;
        }
        
        _teamTextField.text = currentSettings.team.team_name;
    } else if (!newPhoto) {
        photo = [[Photo alloc] init];
        newPhoto = YES;
        _deleteButton.enabled = NO;
        _deleteButton.hidden = YES;
        _photonameTextField.text = @"";
        _descriptionTextView.text = @"";
        [_userButton setTitle:@"User" forState:UIControlStateNormal];
        _photoImage.image = [currentSettings normalizedImage:[UIImage imageNamed:@"photo_not_available.png"] scaledToSize:200];
        _gameButton.enabled = NO;
        user = currentSettings.user;
        photo.owner = currentSettings.user.userid;
        [_cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
        [_featuredSwitch setOn:NO];
        _pendingLabel.hidden = YES;
        _approvalSwitch.hidden = YES;
        _approvalSwitch.enabled = NO;
    }
    
    if ([currentSettings isSiteOwner]) {
        _featuredSwitch.enabled = YES;
        _featuredSwitch.hidden = NO;
        _featuredLabel.hidden = NO;
    } else {
        _featuredSwitch.enabled = NO;
        _featuredSwitch.hidden = YES;
        _featuredLabel.hidden = YES;
        
        if ((currentSettings.user.userid.length > 0) && (currentSettings.sport.review_media)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Your photo will not be available until the administrator approves the photo." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if (user)
        [_userButton setTitle:user.username forState:UIControlStateNormal];
    
    _gameSelectContainer.hidden = YES;
    _playerSelectContainer.hidden = YES;
}

- (IBAction)gameSelected:(UIStoryboardSegue *)segue {
    if (gameController.thegame) {
        _gameTextField.text = [gameController.thegame vsOpponent];
        _gameButton.enabled = YES;
//        _gameButton.backgroundColor = [UIColor greenColor];
        [_gameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        photo.game = gameController.thegame;
    } else {
        _gameButton.enabled = NO;
//        _gameButton.backgroundColor = [UIColor whiteColor];
        [_gameButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _gameTextField.text = @"";
    }
    _gameSelectContainer.hidden = YES;
}

- (IBAction)playerSelected:(UIStoryboardSegue *)segue {
    if (playerSelectController.player) {
        BOOL insert = YES;
        for (int i = 0; i < photo.athletes.count; i++) {
            if ([[[photo.athletes objectAtIndex:i] athleteid] isEqualToString:playerSelectController.player.athleteid]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Athlete already tagged"
                                                               delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
                insert = NO;
            }
        }
        if (insert) {
            [photo.athletes addObject:playerSelectController.player];
            BOOL addthetag = YES;
            
            // Add athlete to add tag array
            if (addtags.count > 0) {
                for (int cnt = 0; cnt < [addtags count]; cnt++) {
                    if ([[[addtags objectAtIndex:cnt] athleteid] isEqualToString:playerSelectController.player.athleteid]) {
                        addthetag = NO;
                        break;
                    }
                }
            }
            if (addthetag)
                [addtags addObject:playerSelectController.player];
            
            // Remove the tag from remove tag array if
            if (removetags.count > 0) {
                for (int cnt = 0; cnt < removetags.count; cnt++) {
                    if ([[[removetags objectAtIndex:cnt] athleteid] isEqualToString:playerSelectController.player.athleteid]) {
                        [removetags removeObjectAtIndex:cnt];
                        break;
                    }
                }
            }
        }
    }
    _playerSelectContainer.hidden = YES;
    [_playerTableView reloadData];
}

- (IBAction)teamButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"TeamInfoSegue" sender:self];
}

- (IBAction)gameButtonClicked:(id)sender {
    if (photo.schedule.length > 0)
        [self performSegueWithIdentifier:@"GameInfoSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlayerInfoSegue"]) {
        NSIndexPath *indexPath = _playerTableView.indexPathForSelectedRow;
        EditPlayerViewController *destController = segue.destinationViewController;
        destController.player = [photo.athletes objectAtIndex:indexPath.row];
    } else if ([segue.identifier isEqualToString:@"GameSelectSegue"]) {
        gameController = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"GameInfoSegue"]) {
        EditGameViewController *destController = segue.destinationViewController;
        destController.game = photo.game;
    } else if ([segue.identifier isEqualToString:@"UserInfoSegue"]) {
        EditUserViewController *destController = segue.destinationViewController;
        destController.theuser = user;
    } else if ([segue.identifier isEqualToString:@"PlayerSelectSegue"]) {
        playerSelectController = segue.destinationViewController;
    } else if (([segue.identifier isEqualToString:@"TeamInfoSegue"])) {
        EditTeamViewController *destController = segue.destinationViewController;
        destController.team = currentSettings.team;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [photo.athletes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayerTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Athlete *athlete = [photo.athletes objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = athlete.full_name;
    cell.imageView.image = [currentSettings getRosterTinyImage:athlete];
    cell.detailTextLabel.text = athlete.position;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Players - Swipe to Delete";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Add to remove tag array
        BOOL remtag = YES;
        if (removetags.count > 0) {
            for (int cnt = 0; cnt < removetags.count; cnt++) {
                if ([[[removetags objectAtIndex:cnt] athleteid] isEqualToString:[[photo.athletes objectAtIndex:indexPath.row] athleteid]]) {
                    remtag = NO;
                    break;
                }
            }
        }
        if (remtag)
            [removetags addObject:[photo.athletes objectAtIndex:indexPath.row]];
        
        // Remove from add tag array
        for (int cnt = 0; cnt < addtags.count; cnt++) {
            if ([[[addtags objectAtIndex:cnt] athleteid] isEqualToString:[[photo.athletes objectAtIndex:indexPath.row] athleteid]]) {
                [addtags removeObjectAtIndex:cnt];
                break;
            }
        }
        
        [photo.athletes removeObjectAtIndex:indexPath.row];
    }
    [_playerTableView reloadData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _gameTextField) {
        [textField resignFirstResponder];
        _gameSelectContainer.hidden = NO;
        gameController.thegame = nil;
        [gameController viewWillAppear:YES];
    } else if (textField == _teamTextField)
        [textField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _teamTextField) {
        return NO;
    } else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    activeField = textView;
}

- (IBAction)submitButtonClicked:(id)sender {
    NSURL *aurl;
    NSMutableDictionary *photoDict;
    
    if (newPhoto) {
        // Upload photo before storing data
        [self uploadImage:photo];
    } else {
        if (_approvalSwitch.isOn)
            photo.pending = NO;
        else
            photo.pending = YES;
        
        aurl = [NSURL URLWithString:[sportzServerInit getPhoto:photo.photoid Token:currentSettings.user.authtoken]];

        photoDict =  [[NSMutableDictionary alloc] initWithObjectsAndKeys: _photonameTextField.text, @"displayname", _descriptionTextView.text, @"description",
                      currentSettings.team.teamid, @"team_id", currentSettings.user.userid, @"user_id",
                      [[NSNumber numberWithBool:photo.pending] stringValue],  @"pending", nil];
        
        if (photo.game.id.length > 0)
            [photoDict setObject:photo.game.id forKey:@"gameschedule_id"];
        
        if (photo.gamelog.length > 0)
            [photoDict setObject:photo.gamelog forKey:@"gamelog_id"];
        
        if (photo.lacross_scoring_id.length > 0)
            [photoDict setObject:photo.lacross_scoring_id forKey:@"lacross_scoring_id"];
        else if (photo.soccer_scoring_id.length > 0)
            [photoDict setObject:photo.soccer_scoring_id forKey:@"soccer_scoring_id"];
        else if (photo.hockey_scoring_id.length > 0)
            [photoDict setObject:photo.hockey_scoring_id forKey:@"hockey_scoring_id"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:photoDict, @"photo", nil];
        
        NSError *jsonSerializationError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
        
        if (!jsonSerializationError) {
            NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"Serialized JSON: %@", serJson);
        } else {
            NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        
        if (newPhoto) {
            [request setHTTPMethod:@"POST"];
        } else {
            [request setHTTPMethod:@"PUT"];
        }
        
        [request setHTTPBody:jsonData];
        
        //Capturing server response
        NSURLResponse* response;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
        NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
        NSLog(@"%@", serverData);
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([httpResponse statusCode] == 200) {
            
            if (addtags.count > 0) {
                [self addPhotoTags:photo];
            }
            if (removetags.count > 0) {
                [self removePhotoTags:photo];
            }
            
            if (_featuredSwitch.isOn) {
                [currentSettings.teamPhotos addFeaturedPhoto:photo];
                [currentSettings.teamPhotos saveFeaturedPhotos];
                photo.pending = false;
            } else if ([currentSettings.teamPhotos isFeaturedPhoto:photo]) {
                [currentSettings.teamPhotos removeFeaturedPhoto:photo];
                [currentSettings.teamPhotos saveFeaturedPhotos];
            }            

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update sucessful!"
                                                            message:@"Photo updated"
                                                           delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error updating photo data"
                                                            message:[NSString stringWithFormat:@"%d", [httpResponse statusCode]]
                                                           delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
    }
}

- (IBAction)tagPlayersButtonClicked:(id)sender {
    _playerSelectContainer.hidden = NO;
    playerSelectController.player = nil;
    [playerSelectController viewWillAppear:YES];
}

- (IBAction)cameraRollButtonClicked:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        
        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"]) {
            imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
            UIPopoverController *apopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            apopover.delegate = self;
            
            // set contentsize
            [apopover setPopoverContentSize:CGSizeMake(220,300)];
            
            [apopover presentPopoverFromRect:CGRectMake(700,1000,10,10) inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = apopover;
        } else {
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        newmedia = NO;
    }
}

- (void)addPhotoTags:(Photo *)aphoto {
    NSURL *aurl = [NSURL URLWithString:[sportzServerInit tagAthletesPhoto:photo Token:currentSettings.user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];    
    NSMutableDictionary *tagDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [addtags count]; i++) {
        [tagDict setObject:[[addtags objectAtIndex:i] athleteid] forKey:[[addtags objectAtIndex:i] logname]];
    }
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tagDict, @"photo", nil];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:jsonData];
    
    //Capturing server response
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&jsonSerializationError];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error updating photo data"
                                                        message:[NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        NSDictionary *photodict = [json objectForKey:@"photo"];
        photo.players = [photodict objectForKey:@"players"];
    }
}

- (void)removePhotoTags:(Photo *)aphoto {
    NSURL *aurl = [NSURL URLWithString:[sportzServerInit untagAthletesPhoto:photo Token:currentSettings.user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *tagDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [removetags count]; i++) {
        [tagDict setObject:[[removetags objectAtIndex:i] athleteid] forKey:[[removetags objectAtIndex:i] logname]];
    }
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tagDict, @"photo", nil];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:jsonData];
    
    //Capturing server response
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&jsonSerializationError];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error updating photo data" message:[json objectForKey:@"error"]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        NSDictionary *photodict = [json objectForKey:@"photo"];
        photo.players = [photodict objectForKey:@"players"];
    }
}


- (IBAction)cameraButtonClicked:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        
        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"]) {
            newmedia = YES;
            UIPopoverController *apopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            apopover.delegate = self;
            
            // set contentsize
            [apopover setPopoverContentSize:CGSizeMake(220,300)];
            
            [apopover presentPopoverFromRect:CGRectMake(700,1000,10,10) inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = apopover;
        } else {
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
        newmedia = YES;
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self.popover dismissPopoverAnimated:YES];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        imgData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1.0);
        NSLog(@"%lu", (unsigned long)[imgData length]);
        UIImage *image = [[UIImage alloc] initWithData:imgData];
        
        if (newmedia)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
        
        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"]) {
            _photoImage.image = [currentSettings normalizedImage:image scaledToSize:700];
            CGSize imageviewsize;
            
            if (image.size.width > image.size.height)
                imageviewsize = CGSizeMake(700.0, 525.0);
            else
                imageviewsize = CGSizeMake(525.0, 700.0);
            
    //        CGFloat corrrectImageViewHeight = (imageviewsize.width/_photoImage.image.size.width) * _photoImage.image.size.height;
    //        _photoImage.frame = CGRectMake(_photoImage.frame.origin.x, _photoImage.frame.origin.y, _photoImage.image.size.width,
    //                                       _photoImage.image.size.height);
    //        _photoImage.frame = CGRectMake(_photoImage.frame.origin.x, _photoImage.frame.origin.x, CGRectGetWidth(_photoImage.bounds),
    //                                       corrrectImageViewHeight);
            _photoImage.frame = CGRectMake(_photoImage.frame.origin.x,_photoImage.frame.origin.y, imageviewsize.width, imageviewsize.height);
        } else {
            _photoImage.image = [currentSettings normalizedImage:image scaledToSize:200];
        }
        imageselected = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
   }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)imag finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil

                              cancelButtonTitle:@"OK"                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)uploadImage:(Photo *)photo {
    if ((imageselected) && (_photonameTextField.text.length > 0)) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [_activityIndicator startAnimating];
        // Upload image data.  Remember to set the content type.
        NSString *randomstr = [self shuffledAlphabet];
        NSString *photopath = [NSString stringWithFormat:@"%@%@%@%@%@", [[currentSettings getBucket] name], @"/uploads/photos/",
                               currentSettings.team.teamid, @"_", randomstr];
        imagepath = [NSString stringWithFormat:@"%@%@%@%@%@%@", @"uploads/photos/", currentSettings.team.teamid, @"_", randomstr, @"/",
                                                            _photonameTextField.text];
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:_photonameTextField.text inBucket:photopath];
        
        por.contentType = @"image/jpeg";
        UIImage *image = [currentSettings normalizedImage:[[UIImage alloc] initWithData:imgData] scaledToSize:1024];
        imgData = nil;
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        por.data = imageData;
        imagesize = imageData.length;
        por.delegate = self;
        
        // Put the image data into the specified s3 bucket and object.
        [[currentSettings getS3] putObject:por];
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select an image or give it a name!" delegate:nil
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        return NO;
    }
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [_activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSURL *url = [NSURL URLWithString:[sportzServerInit newPhoto:currentSettings.user.authtoken]];
    NSMutableDictionary *photoDict =  [[NSMutableDictionary alloc] initWithObjectsAndKeys: _photonameTextField.text, @"filename",
                                       _photonameTextField.text, @"displayname", imagepath, @"filepath", @"image/jpeg", @"filetype",
                                       [NSString stringWithFormat:@"%d", imagesize], @"filesize", _descriptionTextView.text, @"description",
                                       currentSettings.team.teamid, @"team_id", currentSettings.user.userid, @"user_id",
                                       [[NSNumber numberWithBool:photo.pending] stringValue], @"pending", nil];
    
    if (gameController.thegame) {
        [photoDict setObject:gameController.thegame.id forKey:@"gameschedule_id"];
        
//        if (gameplaySelectController.play)
//            [photoDict setObject:gameplaySelectController.play.gamelogid forKey:@"gamelog_id"];
    }
    
    NSMutableURLRequest *urlrequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:photoDict, @"photo", nil];
    
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [urlrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlrequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [urlrequest setHTTPMethod:@"POST"];
    [urlrequest setHTTPBody:jsonData];
    
    //Capturing server response
    NSURLResponse* urlresponse;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlrequest  returningResponse:&urlresponse error:&jsonSerializationError];
    NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)urlresponse;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([httpResponse statusCode] == 200) {
        NSDictionary *items = [serverData objectForKey:@"photo"];
        photo = [[Photo alloc] initWithDirectory:items];
        
        if (newPhoto) {
            photo.photoid = [items objectForKey:@"_id"];
            newPhoto = NO;
        }
        
        if (addtags.count > 0) {
            [self addPhotoTags:photo];
        }
        
        if (_featuredSwitch.isOn) {
            [currentSettings.teamPhotos addFeaturedPhoto:photo];
            [currentSettings.teamPhotos saveFeaturedPhotos];
            photo.pending = false;
        } else if ([currentSettings.teamPhotos isFeaturedPhoto:photo]) {
            [currentSettings.teamPhotos removeFeaturedPhoto:photo];
            [currentSettings.teamPhotos saveFeaturedPhotos];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload sucessful!"
                                                        message:@"Photo uploaded"
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error uploading photo"
                                                        message:[NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Upload Error" delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
    [_activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (NSString *)shuffledAlphabet {
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    // Get the characters into a C array for efficient shuffling
    NSUInteger numberOfCharacters = [alphabet length];
    unichar *characters = calloc(numberOfCharacters, sizeof(unichar));
    [alphabet getCharacters:characters range:NSMakeRange(0, numberOfCharacters)];
    
    // Perform a Fisher-Yates shuffle
    for (NSUInteger i = 0; i < numberOfCharacters; ++i) {
        NSUInteger j = (arc4random_uniform(numberOfCharacters - i) + i);
        unichar c = characters[i];
        characters[i] = characters[j];
        characters[j] = c;
    }
    
    // Turn the result back into a string
    NSString *result = [NSString stringWithCharacters:characters length:numberOfCharacters];
    free(characters);
    return result;
}
/*
- (IBAction)selectPhotoGamePlayEdit:(UIStoryboardSegue *)segue {
    if (gameplaySelectController.play) {
        _playtagTextField.text = gameplaySelectController.play.logentry;
        photo.gamelog = gameplaySelectController.play.gamelogid;
    } else {
        _playtagTextField.text = @"";
        photo.gamelog = @"";
    }
    _gamelogContainer.hidden = YES;
}
*/
- (IBAction)deleteButtonClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Photo?"
                                                    message:@"All photo tags will also be deleted!"
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Confirm"]) {
        NSURL *url = [NSURL URLWithString:[sportzServerInit deletePhoto:photo.photoid Token:currentSettings.user.authtoken]];
        NSMutableURLRequest *urlrequest = [NSMutableURLRequest requestWithURL:url];
        NSDictionary *jsonDict = [[NSDictionary alloc] init];        
        NSError *jsonSerializationError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
        
        if (!jsonSerializationError) {
            NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"Serialized JSON: %@", serJson);
        } else {
            NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        
        [urlrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlrequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [urlrequest setHTTPMethod:@"DELETE"];
        [urlrequest setHTTPBody:jsonData];
        
        //Capturing server response
        NSURLResponse* urlresponse;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlrequest  returningResponse:&urlresponse error:&jsonSerializationError];
        NSMutableDictionary *photoDict = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)urlresponse;
        if ([httpResponse statusCode] == 200) {
            
            if ([currentSettings.teamPhotos isFeaturedPhoto:photo]) {
                [currentSettings.teamPhotos removeFeaturedPhoto:photo];
                [currentSettings.teamPhotos saveFeaturedPhotos];
            }
            
            currentSettings.photodeleted = YES;
            
            if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"manager"])
                [self.navigationController popViewControllerAnimated:YES];
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Photo"
                                                            message:[NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]]
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
    } else if ([title isEqualToString:@"Ok"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)saveBarButtonClicked:(id)sender {
    [self submitButtonClicked:sender];
}

- (IBAction)deleteBarButtonClicked:(id)sender {
    [self deleteButtonClicked:sender];
}

- (IBAction)cameraBarButtonClicked:(id)sender {
    [self cameraButtonClicked:sender];
}

- (IBAction)cameraRollBarButtonClicked:(id)sender {
    [self cameraRollButtonClicked:sender];
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
