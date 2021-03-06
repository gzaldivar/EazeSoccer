//
//  EazesportzRetrieveSponsors.m
//  EazeSportz
//
//  Created by Gil on 1/10/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazesportzRetrieveSponsors.h"
#import "EazesportzAppDelegate.h"
#import "sportzServerInit.h"
#import "EazesportzImage.h"

@implementation EazesportzRetrieveSponsors {
    long responseStatusCode;
    NSMutableArray *serverData;
    NSMutableArray *pricearray, *levelsarray, *playerads;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    long adcount, adindex, adlevel;
}

@synthesize sponsors;

- (id)init {
    if (self = [super init]) {
        adindex = adlevel = 0;
        pricearray = [[NSMutableArray alloc] init];
        return self;
    } else
        return nil;
}

- (void)retrieveSponsors:(NSString *)sportid Token:(NSString *)authtoken {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url;
    
    if (authtoken.length > 0)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SportzServerUrl"],
                                    @"/sports/", sportid, @"/sponsors.json?auth_token=", authtoken]];
    else
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SportzServerUrl"],
                                    @"/sports/", sportid, @"/sponsors.json"]];
    
    originalRequest = [NSURLRequest requestWithURL:url];
    [[NSURLConnection alloc] initWithRequest:originalRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = [httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SponsorListChangedNotification" object:nil
                                                      userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Network Error", @"Result", nil]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
    
    if (responseStatusCode == 200) {
/*        if (sponsors) {
            NSMutableArray *sponsorlist = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < serverData.count; i++) {
                Sponsor *sponsor = [[Sponsor alloc] initWithDirectory:[serverData objectAtIndex:i]];
                [sponsorlist addObject:sponsor];
            }
            
            [self cleanUpSponsorImageList:sponsorlist];
            [self replaceSponsorImages:sponsorlist];
        } else { */
            sponsors = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < serverData.count; i++) {
                Sponsor *sponsor = [[Sponsor alloc] initWithDirectory:[serverData objectAtIndex:i]];
                [sponsor loadImages];
                [sponsors addObject:sponsor];
            }
//        }
        
        if (sponsors.count > 0) {
            NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"adprice" ascending:YES];
            NSArray *descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
            [sponsors sortedArrayUsingDescriptors:descriptors];

            currentSettings.sport.hideAds = YES;
            pricearray = [[NSMutableArray alloc] init];
            playerads = [[NSMutableArray alloc] init];
            
            NSMutableArray *adlist = [[NSMutableArray alloc] init];
            float oldprice = 100000000.0;
            
            for (int i = 0; i < sponsors.count; i++) {
                
                if (oldprice > [[sponsors objectAtIndex:i] adprice]) {
                    
                    if (adlist.count > 0) {
                        [pricearray addObject:adlist];
                    }
                    
                    adlist = [[NSMutableArray alloc] init];
                }
                
                if ([[sponsors objectAtIndex:i] playerad])
                    [playerads addObject:[sponsors objectAtIndex:i]];
                else
                    [adlist addObject:[sponsors objectAtIndex:i]];
                
                oldprice = [[sponsors objectAtIndex:i] adprice];
            }
            
            if (adlist.count > 0)
                [pricearray addObject:adlist];
            
            levelsarray = [[NSMutableArray alloc] init];
            double cnt = (double)pricearray.count;
            
            for (int i = 0; i < pricearray.count; i++) {
                [levelsarray addObject:[NSNumber numberWithDouble:pow(2, cnt)]];
                cnt -= 1.0;
            }
        } else {
            pricearray = nil;
            playerads = nil;
            levelsarray = nil;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SponsorListChangedNotification" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SponsorListChangedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error Retreving Sponsors", @"Result", nil]];
    }
}

- (void)resetLevelsArray {
    adlevel = pricearray.count - 1;
    adindex = 0;
    
    if (pricearray.count == 1) {
        levelsarray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < pricearray.count; i++)
            [levelsarray addObject:[NSNumber numberWithInt:0]];
    } else {
        levelsarray = nil;
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse) {
        NSMutableURLRequest *newrequest = [originalRequest mutableCopy];
        [newrequest setURL:[request URL]];
        return  newrequest;
    } else {
        return request;
    }
}

- (void)replaceSponsorImages:(NSMutableArray *)sponsorlist {
    for (int i = 0; i < sponsors.count; i++) {
        for (int cnt = 0; cnt < sponsorlist.count; cnt++) {
            if ([[[sponsors objectAtIndex:i] sponsorid] isEqualToString:[[sponsorlist objectAtIndex:cnt] sponsorid]]) {
                NSLog(@"sponsor ad banner i%d %@", i, [[sponsors objectAtIndex:i] adbanner_updated_at]);
                NSLog(@"list ad banner cnt%d %@", cnt, [[sponsorlist objectAtIndex:i] adbanner_updated_at]);
                if ([[[sponsors objectAtIndex:i] sponsorpic_updated_at]
                                                compare:[[sponsorlist objectAtIndex:cnt] sponsorpic_updated_at]] != NSOrderedSame)
                    [[sponsorlist objectAtIndex:cnt] loadImages];
                else if ([[[sponsors objectAtIndex:i] adbanner_updated_at]
                                                compare:[[sponsorlist objectAtIndex:cnt] adbanner_updated_at]] != NSOrderedSame) {
                    [[sponsorlist objectAtIndex:cnt] loadImages];
                }
                break;
            }
        }
    }
}

- (void)cleanUpSponsorImageList:(NSMutableArray *)sponsorlist {
    
    for (int i = 0; i < sponsors.count; i++) {
        BOOL found = NO;
        
        for (int cnt = 0; cnt < sponsorlist.count; cnt++) {
            if ([[[sponsorlist objectAtIndex:cnt] sponsorid] isEqualToString:[[sponsors objectAtIndex:i] sponsorid] ]) {
                found = YES;
                break;
            }
        }
        
        if (!found) {
            [sponsors removeObjectAtIndex:i];
        }
    }
    
    for (int i = 0; i < sponsorlist.count; i++) {
        BOOL found = NO;
        
        for (int cnt = 0; cnt < sponsors.count; cnt++) {
            if ([[[sponsors objectAtIndex:cnt] sponsorid] isEqualToString:[[sponsorlist objectAtIndex:i] sponsorid] ]) {
                found = YES;
                break;
            }
        }
        
        if (!found) {
            [sponsors addObject:[sponsorlist objectAtIndex:i]];
        }
    }
}

- (Sponsor *)getSponsorAd {
    
    if (sponsors.count > 0) {
        int numbers = (int)pow((double)pricearray.count, 2);
        float randomNumber = arc4random_uniform(numbers) + (float)arc4random_uniform(numbers + 1)/numbers;
        NSUInteger n=0;
        float totalPercentage= 0.0;
        
        for (NSUInteger i = 0; i < levelsarray.count; i++)  {
            totalPercentage += [levelsarray[i] floatValue];
            
            if( totalPercentage >= randomNumber)  // This case we don't care about
                // the comparison precision
            {
                break;
            }
            
            n++;
        }
        
        NSUInteger randomIndex = arc4random() % [[pricearray objectAtIndex:n] count];
        return [[pricearray objectAtIndex:n] objectAtIndex:randomIndex];
    } else
        return nil;
      
}

- (Sponsor *)getPlayerAd:(Athlete *)athlete {
    NSMutableArray *adlist = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < playerads.count; i++) {
        if ([[[playerads objectAtIndex:i] athlete_id] isEqualToString:athlete.athleteid]) {
            [adlist addObject:[playerads objectAtIndex:i]];
        }
    }
    
    if (adlist.count > 0) {
        NSUInteger randomIndex = arc4random() % [adlist count];
        return [adlist objectAtIndex:randomIndex];
    } else
        return nil;
}

- (BOOL)allPlayerAds {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerad==%d", YES];
    NSArray *results = [pricearray filteredArrayUsingPredicate:predicate];
    
    if (results.count == pricearray.count)
        return  YES;
    else
        return NO;
}

@end
