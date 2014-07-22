//
//  SoccerGoalstat.h
//  EazeSportz
//
//  Created by Gilbert Zaldivar on 6/29/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoccerGoalstat : NSObject

@property (nonatomic, strong) NSString *soccer_stat_id;
@property (nonatomic, strong) NSString *soccer_goalstat_id;
@property (nonatomic, strong) NSString *athlete_id;
@property (nonatomic, strong) NSString *visitor_roster_id;

@property (nonatomic, strong) NSNumber *saves;
@property (nonatomic, strong) NSNumber *goals_allowed;
@property (nonatomic, strong) NSNumber *minutes_played;
@property (nonatomic, strong) NSNumber *period;

@property (nonatomic, assign) BOOL dirty;

- (id)initWithDictionary:(NSDictionary *)soccer_goalstat_dictionary;

- (NSDictionary *)getDictionary;

@end