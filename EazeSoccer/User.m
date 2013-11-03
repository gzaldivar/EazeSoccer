//
//  User.m
//  sportzSoftwareHome
//
//  Created by Gil on 2/6/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;
@synthesize authtoken;
@synthesize email;
@synthesize userid;
@synthesize admin;
@synthesize userUrl;
@synthesize tiny;
@synthesize userthumb;
@synthesize bio_alert;
@synthesize blog_alert;
@synthesize media_alert;
@synthesize stat_alert;
@synthesize score_alert;
@synthesize teammanagerid;
@synthesize isactive;
@synthesize avatarprocessing;
@synthesize tier;

@synthesize awskeyid;
@synthesize awssecretkey;

- (BOOL)isBasic {
    if ([tier isEqualToString:@"Basic"])
        return YES;
    else
        return NO;
}

- (id)initWithDictionary:(NSDictionary *)userDictionary {
    if ((self = [super init]) && (userDictionary.count > 0)) {
        email = [userDictionary objectForKey:@"email"];
        userid = [userDictionary objectForKey:@"id"];
        username = [userDictionary objectForKey:@"name"];
        avatarprocessing = [[userDictionary objectForKey:@"avatarprocessing"] boolValue];
        
        if ((NSNull *)[userDictionary objectForKey:@"avatarthumburl"] != [NSNull null])
            userthumb = [userDictionary objectForKey:@"avatarthumburl"];
        else
            userthumb = @"";
        
        if ((NSNull *)[userDictionary objectForKey:@"avatartinyurl"] != [NSNull null])
            tiny = [userDictionary objectForKey:@"avatartinyurl"];
        else
            tiny = @"";
        
        isactive = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"is_active"] integerValue]];
        bio_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"bio_alert"] integerValue]];
        blog_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"blog_alert"] integerValue]];
        media_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"media_alert"] integerValue]];
        stat_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"stat_alert"] integerValue]];
        score_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"score_alert"] integerValue]];
        admin = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"admin"] integerValue]];
        
        return self;
    } else {
        return nil;
    }
}

@end
