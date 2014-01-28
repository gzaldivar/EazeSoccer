//
//  EazeFootballGameStatsViewController.m
//  EazeSportz
//
//  Created by Gil on 1/18/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazeFootballGameStatsViewController.h"
#import "EazesportzAppDelegate.h"
#import "EazesportzRetrieveFootballStatTotals.h"
#import "FootballStatTotals.h"
#import "EazesportzFootballStatTotalsTableCell.h"
#import "EazesportzRetrievePassingGameStats.h"
#import "EazesportzRetrieveFootballRushingGameStats.h"
#import "EazesportzRetrieveFootballReceivingStats.h"
#import "EazesportzRetrieveFootballDefenseGameStats.h"
#import "EazesportzRetrieveFootballKickerStats.h"
#import "EazesportzRetrieveFootballReturnerGameStats.h"
#import "EazesportzStatTableHeaderCell.h"
#import "EazeFootballPlayerStatsViewController.h"

@interface EazeFootballGameStatsViewController ()

@end

@implementation EazeFootballGameStatsViewController {
    NSString *visiblestats;
    
    EazesportzRetrieveFootballStatTotals *getTotals;
    EazesportzRetrievePassingGameStats *getPassing;
    EazesportzRetrieveFootballRushingGameStats *getRushing;
    EazesportzRetrieveFootballReceivingStats *getReceiving;
    EazesportzRetrieveFootballDefenseGameStats *getDefense;
    EazesportzRetrieveFootballKickerStats *getKicker;
    EazesportzRetrieveFootballReturnerGameStats *getReturner;
    
    NSMutableArray *puntreturner, *kickreturner;
}

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
    
    getTotals = [[EazesportzRetrieveFootballStatTotals alloc] init];
    getPassing = [[EazesportzRetrievePassingGameStats alloc] init];
    getRushing = [[EazesportzRetrieveFootballRushingGameStats alloc] init];
    getReceiving = [[EazesportzRetrieveFootballReceivingStats alloc] init];
    getDefense = [[EazesportzRetrieveFootballDefenseGameStats alloc] init];
    getKicker = [[EazesportzRetrieveFootballKickerStats alloc] init];
    getReturner = [[EazesportzRetrieveFootballReturnerGameStats alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)teamButtonClicked:(id)sender {
    visiblestats = @"Team";
    [_statTableView reloadData];
}

- (IBAction)passButtonClicked:(id)sender {
    visiblestats = @"Pass";
    [_statTableView reloadData];
}

- (IBAction)receiverButtonClicked:(id)sender {
    visiblestats = @"Rec";
    [_statTableView reloadData];
}

- (IBAction)rushingButtonClicked:(id)sender {
    visiblestats = @"Rush";
    [_statTableView reloadData];
}

- (IBAction)defenseButtonClicked:(id)sender {
    visiblestats = @"Def";
    [_statTableView reloadData];
}

- (IBAction)kickerButtonClicked:(id)sender {
    visiblestats = @"Kick";
    [_statTableView reloadData];
}

- (IBAction)returnerButtonClicked:(id)sender {
    visiblestats = @"Ret";
    [_statTableView reloadData];
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    visiblestats = @"Team";
    
    _homeImage.image = [currentSettings.team getImage:@"tiny"];
    _visitorImage.image = [game opponentImage];
    _homeLabel.text = currentSettings.team.mascot;
    _visitorLabel.text = game.opponent_mascot;
    _clockLabel.text = game.currentgametime;
    _homeScore.text = [NSString stringWithFormat:@"%d", [currentSettings teamTotalPoints:game.id]];
    _visitorScore.text = [game.opponentscore stringValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotTotals:) name:@"TotalsGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPassing:) name:@"PassingGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotRushing:) name:@"RushingGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotReceiving:) name:@"ReceivingGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotDefense:) name:@"DefenseGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotKicker:) name:@"KickerGameStatsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotReturner:) name:@"ReturnerGameStatsNotification" object:nil];
    
    [getTotals retrieveFootballStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getDefense retrieveFootballDefenseStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getPassing retrieveFootballPassingStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getReceiving retrieveFootballReceivingStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getRushing retrieveFootballRushingStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getKicker retrieveFootballKickerStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    [getReturner retrieveFootballReturnerStats:currentSettings.sport.id Team:currentSettings.team.teamid Game:game.id];
    
    _passButton.enabled = NO;
    _rushButton.enabled = NO;
    _receiverButton.enabled = NO;
    _defenseButton.enabled = NO;
    _kickerButton.enabled = NO;
    _returnerButton.enabled = NO;
}

- (void)gotTotals:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        visiblestats = @"Team";
        [_statTableView reloadData];
    }
}

- (void)gotPassing:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _passButton.enabled = YES;
    }
}

- (void)gotRushing:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _rushButton.enabled = YES;
    }
}

- (void)gotReceiving:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _receiverButton.enabled = YES;
    }
}

- (void)gotDefense:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _defenseButton.enabled = YES;
    }
}

- (void)gotKicker:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _kickerButton.enabled = YES;
    }
}

- (void)gotReturner:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        _returnerButton.enabled = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([visiblestats isEqualToString:@"Kick"])
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([visiblestats isEqualToString:@"Team"]) {
        return 6;
    } else if ([visiblestats isEqualToString:@"Pass"]) {
        return getPassing.passing.count + 1;
    } else if ([visiblestats isEqualToString:@"Rush"]) {
        return getRushing.rushing.count + 1;
    } else if ([visiblestats isEqualToString:@"Rec"]) {
        return getReceiving.receiving.count + 1;
    } else if ([visiblestats isEqualToString:@"Def"]) {
        return getDefense.defense.count + 1;
    } else if ([visiblestats isEqualToString:@"Kick"]) {
        if (section == 0)
            return getKicker.kicker.count + 1;
        else
            return getKicker.punter.count + 1;
    } else if ([visiblestats isEqualToString:@"Ret"]) {
        if (section == 0) {
            puntreturner = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < getReturner.returner.count; i++) {
                FootballReturnerStats *returner = [getReturner.returner objectAtIndex:i];
                
                if (returner.punt_return > 0)
                    [puntreturner addObject:returner];
            }
            return puntreturner.count + 1;
        } else {
            kickreturner = [[NSMutableArray alloc] init];
            for (int i = 0; i < getReturner.returner.count; i++) {
                
                FootballReturnerStats *returner = [getReturner.returner objectAtIndex:i];
                
                if (returner.koreturn > 0)
                    [kickreturner addObject:returner];
            }
            return kickreturner.count + 1;
        }
    } else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([visiblestats isEqualToString:@"Team"]) {
        EazesportzFootballStatTotalsTableCell *cell = [[EazesportzFootballStatTotalsTableCell alloc] init];
        static NSString *CellIdentifier = @"TotalsStatsTableCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzFootballStatTotalsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch (indexPath.row) {
            case 0:
                cell.statTitleLabel.text = @"First Downs";
                cell.statLabel.text = [getTotals.totals.totalfirstdowns stringValue];
                break;
            case 1:
                cell.statTitleLabel.text = @"Total Yards";
                cell.statLabel.text = [getTotals.totals.totalyards stringValue];
                break;
            case 2:
                cell.statTitleLabel.text = @"Passing";
                cell.statLabel.text = [getTotals.totals.passingtotalyards stringValue];
                break;
            case 3:
                cell.statTitleLabel.text = @"Rushing";
                cell.statLabel.text = [getTotals.totals.rushingtotalyards stringValue];
                break;
            case 4:
                cell.statTitleLabel.text = @"Penalties";
                cell.statLabel.text = [NSString stringWithFormat:@"%d%@%d",
                                       [getTotals.totals.penalties intValue], @"/", [getTotals.totals.penaltyyards intValue]];
                break;
                
            default:
                cell.statTitleLabel.text = @"Turnovers";
                cell.statLabel.text = [getTotals.totals.turnovers stringValue];
                break;
        }
        return cell;
    } else if ([visiblestats isEqualToString:@"Pass"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        FootballPassingStat *stat;
        
        if (indexPath.row < getPassing.passing.count) {
            stat = [getPassing.passing objectAtIndex:indexPath.row];
            cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
        } else {
            stat = getPassing.totals;
            cell.playerLabel.text = @"Totals";
        }
        
        cell.label1.text = [stat.completions stringValue];
        cell.label2.text = [stat.attempts stringValue];
        cell.label3.text = [stat.yards stringValue];
        
        if ([stat.yards intValue] > 0)
            cell.label4.text = [NSString stringWithFormat:@"%.02f", [stat.yards floatValue]/[stat.completions floatValue]];
        else
            cell.label4.text = @"0.0";
        
        cell.label5.text = [stat.td stringValue];
        cell.label6.text = [stat.interceptions stringValue];
        
        return cell;
    } else if ([visiblestats isEqualToString:@"Rush"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        FootballRushingStat *stat;
        
        if (indexPath.row < getRushing.rushing.count) {
            stat = [getRushing.rushing objectAtIndex:indexPath.row];
            cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
        } else {
            stat = getRushing.totals;
            cell.playerLabel.text = @"Totals";
        }
        
        cell.label1.text = @"";
        cell.label2.text = [stat.attempts stringValue];
        cell.label3.text = [stat.yards stringValue];
        
        if ([stat.yards intValue] > 0)
            cell.label4.text = [NSString stringWithFormat:@"%.02f", [stat.yards floatValue]/[stat.attempts floatValue]];
        else
            cell.label4.text = @"0.0";
        
        cell.label5.text = [stat.longest stringValue];
        cell.label6.text = [stat.td stringValue];
        
        return cell;
    } else if ([visiblestats isEqualToString:@"Rec"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        FootballReceivingStat *stat;
        
        if (indexPath.row < getReceiving.receiving.count) {
            stat = [getReceiving.receiving objectAtIndex:indexPath.row];
            cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
        } else {
            stat = getReceiving.totals;
            cell.playerLabel.text = @"Totals";
        }
        
        cell.label1.text = @"";;
        cell.label2.text = [stat.receptions stringValue];
        cell.label3.text = [stat.yards stringValue];
        
        if ([stat.yards intValue] > 0)
            cell.label4.text = [NSString stringWithFormat:@"%.02f", [stat.yards floatValue]/[stat.receptions floatValue]];
        else
            cell.label4.text = @"0.0";
        
        cell.label5.text = [stat.longest stringValue];
        cell.label6.text = [stat.td stringValue];
        
        return cell;
    } else if ([visiblestats isEqualToString:@"Def"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        FootballDefenseStats *stat;
        
        if (indexPath.row < getDefense.defense.count) {
            stat = [getDefense.defense objectAtIndex:indexPath.row];
            cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
        } else {
            stat = getDefense.totals;
            cell.playerLabel.text = @"Totals";
        }
        
        cell.label1.text = @"";;
        cell.label2.text = [stat.tackles stringValue];
        cell.label3.text = [stat.assists stringValue];
        cell.label4.text = [stat.sacks stringValue];
        cell.label5.text = [stat.interceptions stringValue];
        cell.label6.text = [stat.td stringValue];
        
        return cell;
    } else if ([visiblestats isEqualToString:@"Kick"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.section == 0) {
            FootballPlaceKickerStats *stat;
            
            if (indexPath.row < getKicker.kicker.count) {
                stat = [getKicker.kicker objectAtIndex:indexPath.row];
                cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
            } else {
                stat = getKicker.totals;
                cell.playerLabel.text = @"Totals";
            }
            
            cell.label1.text = @"";;
            cell.label2.text = @"";
            cell.label3.text = @"";
            cell.label4.text = [stat.fgmade stringValue];
            cell.label5.text = [stat.xpmade stringValue];
            cell.label6.text = [NSString stringWithFormat:@"%d", ([stat.fgmade intValue] * 3) + [stat.xpmade intValue]];
        } else {
            FootballPunterStats *stat;
            
            if (indexPath.row < getKicker.punter.count) {
                stat = [getKicker.punter objectAtIndex:indexPath.row];
                cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
            } else {
                stat = getKicker.puntertotals;
                cell.playerLabel.text = @"Totals";
            }
            
            cell.label1.text = @"";;
            cell.label2.text = @"";
            cell.label3.text = @"";
            cell.label4.text = [stat.punts stringValue];
            cell.label5.text = [stat.punts_yards stringValue];
            
            if ([stat.punts_yards intValue] > 0)
                cell.label6.text = [NSString stringWithFormat:@"%.02f", [stat.punts_yards floatValue] / [stat.punts floatValue]];
            else
                cell.label6.text = @"0.0";
        }
        
        return cell;
    } else if ([visiblestats isEqualToString:@"Ret"]) {
        EazesportzStatTableHeaderCell *cell = [[EazesportzStatTableHeaderCell alloc] init];
        static NSString *CellIdentifier = @"StatTableCell";
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        if (cell == nil) {
            cell = [[EazesportzStatTableHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.section == 0) {
            FootballReturnerStats *stat;
            
            if (indexPath.row < puntreturner.count) {
                stat = [puntreturner objectAtIndex:indexPath.row];
                cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
            } else {
                stat = getReturner.totals;
                cell.playerLabel.text = @"Totals";
            }
            
            cell.label1.text = @"";;
            cell.label2.text = @"";
            cell.label3.text = [stat.punt_return stringValue];
            cell.label4.text = [stat.punt_returnyards stringValue];
            
            if ([stat.punt_returnyards intValue] > 0)
                cell.label5.text = [NSString stringWithFormat:@"%.02f", [stat.punt_returnyards floatValue]/[stat.punt_return intValue]];
            else
                cell.label5.text = @"";
            
            cell.label6.text = [stat.punt_returntd stringValue];
            
            return cell;
        } else {
            FootballReturnerStats *stat;
            
            if (indexPath.row < kickreturner.count) {
                stat = [kickreturner objectAtIndex:indexPath.row];
                cell.playerLabel.text = [[currentSettings findAthlete:stat.athlete_id] logname];
            } else {
                stat = getReturner.totals;
                cell.playerLabel.text = @"Totals";
            }
            
            cell.label1.text = @"";;
            cell.label2.text = @"";
            cell.label3.text = [stat.koreturn stringValue];
            cell.label4.text = [stat.koyards stringValue];
            
            if ([stat.koyards intValue] > 0)
                cell.label5.text = [NSString stringWithFormat:@"%.02f", [stat.koyards floatValue]/[stat.koreturn intValue]];
            else
                cell.label5.text = @"";
            
            cell.label6.text = [stat.kotd stringValue];
            
            return cell;
        }
    } else {
        UITableViewCell *cell;
        
        return cell;
    }
     
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (([visiblestats isEqualToString:@"Pass"]) && (indexPath.row < getPassing.passing.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    } else if (([visiblestats isEqualToString:@"Rush"]) && (indexPath.row < getRushing.rushing.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    } else if (([visiblestats isEqualToString:@"Rec"]) && (indexPath.row < getReceiving.receiving.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    } else if (([visiblestats isEqualToString:@"Def"]) && (indexPath.row < getDefense.defense.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    } else if (([visiblestats isEqualToString:@"Kick"]) && (indexPath.row < getKicker.kicker.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    } else if (([visiblestats isEqualToString:@"Ret"]) && (indexPath.row < getReturner.returner.count)) {
        [self performSegueWithIdentifier:@"PlayerStatsSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexpath = [_statTableView indexPathForSelectedRow];
    
    if ([segue.identifier isEqualToString:@"PlayerStatsSegue"]) {
        EazeFootballPlayerStatsViewController *destController = segue.destinationViewController;
        
        if ([visiblestats isEqualToString:@"Pass"])
            destController.player = [currentSettings findAthlete:[[getPassing.passing objectAtIndex:indexpath.row] athlete_id]];
        else if ([visiblestats isEqualToString:@"Rush"])
            destController.player = [currentSettings findAthlete:[[getRushing.rushing objectAtIndex:indexpath.row] athlete_id]];
        else if ([visiblestats isEqualToString:@"Rec"])
            destController.player = [currentSettings findAthlete:[[getReceiving.receiving objectAtIndex:indexpath.row] athlete_id]];
        else if ([visiblestats isEqualToString:@"Def"])
            destController.player = [currentSettings findAthlete:[[getDefense.defense objectAtIndex:indexpath.row] athlete_id]];
        else if ([visiblestats isEqualToString:@"Kick"])
            destController.player = [currentSettings findAthlete:[[getKicker.kicker objectAtIndex:indexpath.row] athlete_id]];
        else if ([visiblestats isEqualToString:@"Ret"])
            destController.player = [currentSettings findAthlete:[[getReturner.returner objectAtIndex:indexpath.row] athlete_id]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *headerView;
    
    if ([visiblestats isEqualToString:@"Pass"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label = (UILabel *)[headerView viewWithTag:1];
        label.text = @"CMP";
        label = (UILabel *)[headerView viewWithTag:2];
        label.text = @"ATT";
        label = (UILabel *)[headerView viewWithTag:3];
        label.text = @"YDS";
        label = (UILabel *)[headerView viewWithTag:4];
        label.text = @"YPA";
        label = (UILabel *)[headerView viewWithTag:5];
        label.text = @"TD";
        label = (UILabel *)[headerView viewWithTag:6];
        label.text = @"INT";
        
    } else if ([visiblestats isEqualToString:@"Rush"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label = (UILabel *)[headerView viewWithTag:1];
        label.text = @"";
        label = (UILabel *)[headerView viewWithTag:2];
        label.text = @"ATT";
        label = (UILabel *)[headerView viewWithTag:3];
        label.text = @"YDS";
        label = (UILabel *)[headerView viewWithTag:4];
        label.text = @"AVG";
        label = (UILabel *)[headerView viewWithTag:5];
        label.text = @"LNG";
        label = (UILabel *)[headerView viewWithTag:6];
        label.text = @"TD";
            
    } else if ([visiblestats isEqualToString:@"Rec"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label = (UILabel *)[headerView viewWithTag:1];
        label.text = @"";
        label = (UILabel *)[headerView viewWithTag:2];
        label.text = @"REC";
        label = (UILabel *)[headerView viewWithTag:3];
        label.text = @"YDS";
        label = (UILabel *)[headerView viewWithTag:4];
        label.text = @"AVG";
        label = (UILabel *)[headerView viewWithTag:5];
        label.text = @"LNG";
        label = (UILabel *)[headerView viewWithTag:6];
        label.text = @"TD";
        
    } else if ([visiblestats isEqualToString:@"Def"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label = (UILabel *)[headerView viewWithTag:1];
        label.text = @"";
        label = (UILabel *)[headerView viewWithTag:2];
        label.text = @"TKL";
        label = (UILabel *)[headerView viewWithTag:3];
        label.text = @"AST";
        label = (UILabel *)[headerView viewWithTag:4];
        label.text = @"SAK";
        label = (UILabel *)[headerView viewWithTag:5];
        label.text = @"INT";
        label = (UILabel *)[headerView viewWithTag:6];
        label.text = @"TD";
        
    } else if ([visiblestats isEqualToString:@"Kick"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (section == 0) {
            UILabel *label = (UILabel *)[headerView viewWithTag:1];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:2];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:3];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:4];
            label.text = @"FG";
            label = (UILabel *)[headerView viewWithTag:5];
            label.text = @"XP";
            label = (UILabel *)[headerView viewWithTag:6];
            label.text = @"PTS";
            label = (UILabel *)[headerView viewWithTag:9];
            label.text = @"Kicker";
        } else {
            UILabel *label = (UILabel *)[headerView viewWithTag:1];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:2];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:3];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:4];
            label.text = @"TOT";
            label = (UILabel *)[headerView viewWithTag:5];
            label.text = @"YDS";
            label = (UILabel *)[headerView viewWithTag:6];
            label.text = @"AVG";
            label = (UILabel *)[headerView viewWithTag:9];
            label.text = @"Punter";
        }
        
    } else if ([visiblestats isEqualToString:@"Ret"]) {
        static NSString *CellIdentifier = @"StatTableHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (section == 0) {
            UILabel *label = (UILabel *)[headerView viewWithTag:1];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:2];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:3];
            label.text = @"RET";
            label = (UILabel *)[headerView viewWithTag:4];
            label.text = @"YDS";
            label = (UILabel *)[headerView viewWithTag:5];
            label.text = @"AVG";
            label = (UILabel *)[headerView viewWithTag:6];
            label.text = @"TD";
            label = (UILabel *)[headerView viewWithTag:9];
            label.text = @"Punts";
        } else {
            UILabel *label = (UILabel *)[headerView viewWithTag:1];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:2];
            label.text = @"";
            label = (UILabel *)[headerView viewWithTag:3];
            label.text = @"RET";
            label = (UILabel *)[headerView viewWithTag:4];
            label.text = @"YDS";
            label = (UILabel *)[headerView viewWithTag:5];
            label.text = @"AVG";
            label = (UILabel *)[headerView viewWithTag:6];
            label.text = @"TD";
            label = (UILabel *)[headerView viewWithTag:9];
            label.text = @"Kickoffs";
        }
        
    } else {
        static NSString *CellIdentifier = @"TotalsHeaderCell";
        
        headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }

    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    
    return headerView;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 30.0;
 }

- (IBAction)refreshButtonClicked:(id)sender {
    [currentSettings retrieveGame:game.id];
    [self viewWillAppear:YES];
}

@end
