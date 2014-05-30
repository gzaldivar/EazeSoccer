//
//  LacrossGoalstat.h
//  EazeSportz
//
//  Created by Gilbert Zaldivar on 5/22/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LacrossGoalstat : NSObject

@property (nonatomic, strong) NSNumber *saves;
@property (nonatomic, strong) NSNumber *goals_allowed;
@property (nonatomic, strong) NSNumber *minutesplayed;
@property (nonatomic, strong) NSNumber *period;

@property (nonatomic, strong) NSString *lacrosstat_id;
@property (nonatomic, strong) NSString *lacross_goalstat_id;
@property (nonatomic, strong) NSString *athlete_id;
@property (nonatomic, strong) NSString *visitor_roster_id;

- (id)initWithDictionary:(NSDictionary *)lacross_goalstat_dictionary;

@end
