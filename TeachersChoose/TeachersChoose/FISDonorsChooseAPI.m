//
//  FISDonorsChooseAPI.m
//  playingWithDonorsChooseAPI
//
//  Created by Damon Skinner on 3/30/15.
//  Copyright (c) 2015 Damon Skinner. All rights reserved.
//

#import "FISDonorsChooseAPI.h"
#import "FISConstants.h"
#import <AFNetworking.h>

@implementation FISDonorsChooseAPI

+(void)getSearchResultsWithKeyword:(NSString *) keyword andCompletionBlock:(void (^)(NSArray *))completionBlock
{
    NSString *donorsChooseURLString = [NSString stringWithFormat:@"%@",DonorsChooseBaseURL];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    NSDictionary *params = @{@"keywords":keyword,@"APIKEY":DonorsChooseAPIKey};
    
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    
    [manager GET:donorsChooseURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *rawResults = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        completionBlock(rawResults[@"proposals"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@",error.localizedDescription);
    }];
}

+(void)getSearchResultsWithLocation:(NSString *) location andCompletionBlock:(void (^)(NSArray *))completionBlock
{
    NSString *donorsChooseURLString = [NSString stringWithFormat:@"%@",DonorsChooseBaseURL];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *params = @{@"location":location,@"APIKEY":DonorsChooseAPIKey};
    
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    
    [manager GET:donorsChooseURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *rawResults = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        
        completionBlock(rawResults[@"proposals"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@",error.localizedDescription);
    }];
}

+(void)getSearchResultsWithParams:(NSDictionary *) params andCompletionBlock:(void (^)(NSArray *))completionBlock
{
    NSString *donorsChooseURLString = [NSString stringWithFormat:@"%@&APIKEY=%@",DonorsChooseBaseURL,DonorsChooseAPIKey];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    

    
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    
    [manager GET:donorsChooseURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *rawResults = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        
        completionBlock(rawResults[@"proposals"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@",error.localizedDescription);
    }];
}

@end
