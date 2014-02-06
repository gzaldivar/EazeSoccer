//
//  FindSiteViewController.m
//  Eazebasketball
//
//  Created by Gil on 9/28/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FindSiteViewController.h"
#import "EazesportzAppDelegate.h"
#import "sportzteamsRegisterLoginViewController.h"
#import "SelectStateViewController.h"
#import "SelectSiteTableViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface FindSiteViewController ()

@end

@implementation FindSiteViewController {
    NSDictionary *stateDictionary;
    NSArray *serverData;
    int responseStatusCode;
    NSMutableData *theData;
    
    NSMutableArray *sportsname, *sportsvalue;
    NSArray *stateList;
    NSMutableArray *countryarray;
    NSString *country, *stateabreviation;
    
    BOOL registerSite;
    Sport *sport;
    
    SelectStateViewController *selectStateController;
}

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
    _zipcodeTextfield.keyboardType = UIKeyboardTypeNumberPad;
//    _stateTextField.inputView = selectStateController.inputView;
    _sportTextField.inputView = _sportPicker.inputView;
    _siteselectView.layer.cornerRadius = 6;
    stateabreviation = @"";
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    NSArray *temparray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    countryarray = [[NSMutableArray alloc] init];
    [countryarray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"United States", @"name", @"US", @"code", nil]];
    [countryarray addObjectsFromArray:temparray];
    plistPath = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    stateDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray * keys = [stateDictionary allKeys];
    stateList = [keys sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _stateTextField.text = @"";
    _zipcodeTextfield.text = @"";
    _sitenameTextField.text = @"";
    _zipcodeTextfield.text = @"";
    
    _stateListContainer.hidden = YES;
    
    _sportPicker.hidden = YES;
    _countryPicker.hidden = YES;
    _statePicker.hidden = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SportzServerUrl"], @"/home.json"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse* response;
    NSError *error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    if ([(NSHTTPURLResponse*)response statusCode] == 200) {
        NSDictionary *thelist = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        sportsname = [[NSMutableArray alloc] init];
        sportsvalue = [[NSMutableArray alloc] init];
        NSArray *thesports = [thelist objectForKey:@"sports_list"];
        for (int i = 0; i < [thesports count]; i++) {
            NSArray *sportlist = [thesports objectAtIndex:i];
            [sportsname addObject:[sportlist objectAtIndex:0]];
            [sportsvalue addObject:[sportlist objectAtIndex:1]];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Retrieving Sports List" delegate:nil
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

- (IBAction)submitButtonClicked:(id)sender {
    if (((_zipcodeTextfield.text.length > 0) || (_cityTextField.text.length > 0) || (_sitenameTextField.text.length > 0) ||
        (_stateTextField.text.length > 0) || (_countryTextField.text.length > 0)) && (_sportTextField.text.length > 0)) {
        [self performSegueWithIdentifier:@"SelectSiteSegue" sender:self];
     } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter valid search criteria! At least Sport is required."
                                                       delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
}

- (IBAction)selectStateFindSite:(UIStoryboardSegue *)segue {
    _stateListContainer.hidden = YES;
    
    if (selectStateController.state) {
        _stateTextField.text = selectStateController.state;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _stateTextField) {
        if ([_countryTextField.text isEqualToString:@"United States"]) {
//            _stateTextField.inputView = selectStateController.inputView;
//            _stateListContainer.hidden = NO;
//            selectStateController.state = nil;
            _stateTextField.text = @"";
//            [selectStateController viewWillAppear:YES];
            [_stateTextField resignFirstResponder];
            _statePicker.hidden = NO;
        }
    } else if (textField == _sportTextField) {
        [_sportTextField resignFirstResponder];
        _sportPicker.hidden = NO;
    } else if (textField == _countryTextField) {
        [_countryTextField resignFirstResponder];
        _countryPicker.hidden = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectStateSegue"]) {
        selectStateController = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"SelectSiteSegue"]) {
        SelectSiteTableViewController *selectSiteController = segue.destinationViewController;
//        selectSiteController.state = selectStateController.stateabreviation;
        selectSiteController.state = stateabreviation;
        selectSiteController.zipcode = _zipcodeTextfield.text;
        selectSiteController.city = _cityTextField.text;
        selectSiteController.country = country;
        selectSiteController.sitename = _sitenameTextField.text;
        selectSiteController.sportname = _sportTextField.text;
    } else if ([segue.identifier isEqualToString:@"RegisterSiteLoginSegue"]) {
        sportzteamsRegisterLoginViewController *destController = segue.destinationViewController;
        destController.sport = sport;
    }
}

//Method to define how many columns/dials to show
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component {
    if (pickerView == _sportPicker)
        return sportsname.count;
    else if (pickerView == _countryPicker)
        return countryarray.count;
    else
        return stateList.count;
}

// Method to show the title of row for a component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _sportPicker)
        return [sportsname objectAtIndex:row];
    else if (pickerView == _countryPicker) {
        NSDictionary *subDict = [countryarray objectAtIndex:row];
        return [subDict objectForKey:@"name"];
    } else {
        return [stateList objectAtIndex:row];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _sportPicker) {
        _sportTextField.text = [sportsvalue objectAtIndex:row];
        _sportPicker.hidden = YES;
    } else if (pickerView == _countryPicker) {
        NSDictionary *subDict = [countryarray objectAtIndex:row];
        _countryTextField.text = [subDict objectForKey:@"name"];
        country = [subDict objectForKey:@"name"];
        _countryPicker.hidden = YES;
    } else {
        _stateTextField.text = [stateList objectAtIndex:row];
        stateabreviation = [stateDictionary objectForKey:[stateList objectAtIndex:row]];
        _statePicker.hidden = YES;
    }
}

@end
