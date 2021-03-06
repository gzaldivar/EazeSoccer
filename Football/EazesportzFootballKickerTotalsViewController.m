//
//  EazesportzFootballKickerTotalsViewController.m
//  EazeSportz
//
//  Created by Gil on 12/3/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "EazesportzFootballKickerTotalsViewController.h"
#import "FootballKickerStats.h"
#import "EazesportzAppDelegate.h"

@interface EazesportzFootballKickerTotalsViewController ()

@end

@implementation EazesportzFootballKickerTotalsViewController {
    FootballKickerStats *stat, *originalstat;
}

@synthesize player;
@synthesize game;

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
    self.title = @"Kicker Totals";
    
    _koattemptsTextField.keyboardType = UIKeyboardTypeNumberPad;
    _touchbacksTextField.keyboardType = UIKeyboardTypeNumberPad;
    _returnedTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [_playerImage setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"apptype"] isEqualToString:@"client"]) {
        _playerImage.image = [currentSettings getRosterTinyImage:player];
        _playerName.text = player.numberLogname;
    } else {
        _playerImage.image = [currentSettings getRosterMediumImage:player];
        _playerName.text = [NSString stringWithFormat:@"%@ vs %@", player.numberLogname, game.opponent_mascot];
        _playerNumber.text = [player.number stringValue];
    }

    stat = [player findFootballKickerStat:game.id];
    
    if (stat.football_kicker_id.length > 0)
        originalstat = [stat copy];
    else
        originalstat = nil;
    
    _koattemptsTextField.text = [stat.koattempts stringValue];
    _touchbacksTextField.text = [stat.kotouchbacks stringValue];
    _returnedTextField.text = [stat.koreturned stringValue];
}

- (IBAction)submitButtonClicked:(id)sender {
    stat.koreturned = [NSNumber numberWithInt:[_returnedTextField.text intValue]];
    stat.koattempts = [NSNumber numberWithInt:[_koattemptsTextField.text intValue]];
    stat.kotouchbacks = [NSNumber numberWithInt:[_touchbacksTextField.text intValue]];
    
    [player updateFootballKickerGameStats:stat];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction)cancelButtonClicked:(id)sender {
    if (originalstat != nil)
        [player updateFootballKickerGameStats:originalstat];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction)saveBarButtonClicked:(id)sender {
    [self submitButtonClicked:sender];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *validRegEx =@"^[0-9.]*$"; //change this regular expression as your requirement
    NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (myStringMatchesRegEx) {
        return (newLength > 3) ? NO : YES;
    } else
        return  NO;
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
