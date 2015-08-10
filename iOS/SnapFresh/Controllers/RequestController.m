/*
 * Copyright 2014 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "RequestController.h"
#import "Constants.h"
#import "SnapRetailer.h"
#import "FarmersMarket.h"

NSString * const kSNAPRetailersDidLoadNotification = @"SNAPRetailersDidLoadNotification";
NSString * const kSNAPRetailersDidNotLoadNotification = @"SNAPRetailersDidNotLoadNotification";
NSString * const kFarmersMarketsDidLoadNotification = @"FarmersMarketsDidLoadNotification";
NSString * const kFarmersMarketsDidNotLoadNotification = @"FarmersMarketsDidNotLoadNotification";

@implementation RequestController

#pragma mark - Send SnapFresh request

- (void)sendSNAPRequestForCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
        NSString *urlString = [NSString stringWithFormat:@"%@%@?address=%@", kSnapFreshBaseURL, kSnapFreshEndpoint, coordinateString];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error)
                                                    {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kSNAPRetailersDidNotLoadNotification object:error];
                                                    }
                                                    else
                                                    {
                                                        NSArray *snapRetailers = [self snapRetailersFromJSON:data error:&error];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kSNAPRetailersDidLoadNotification object:snapRetailers];
                                                    }
                                                }];
        
        [task resume];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"com.shrtlist.snapfresh" code:99 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Invalid coordinate"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSNAPRetailersDidNotLoadNotification object:error];
    }
}

#pragma mark - Send USDA farmers market request

- (void)sendFarmersMarketRequestForCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (CLLocationCoordinate2DIsValid(coordinate))
    {
        NSString *urlString = [NSString stringWithFormat:@"%@%@lat=%f&lng=%f", kUSDABaseURL, kUSDAFarmersMarketSearchEndpoint, coordinate.latitude, coordinate.longitude];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error)
                                                    {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kFarmersMarketsDidNotLoadNotification object:error];
                                                    }
                                                    else
                                                    {
                                                        NSError *localError = nil;
                                                        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];

                                                        [self sendFarmersMarketDetailRequest:jsonDictionary[@"results"] completionHandler:^(NSArray *farmersMarkets, NSError *error) {
                                                            if (error)
                                                            {
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:kFarmersMarketsDidNotLoadNotification object:error];
                                                            }
                                                            else
                                                            {
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:kFarmersMarketsDidLoadNotification object:farmersMarkets];
                                                            }
                                                        }];
                                                    }
                                                }];
        
        [task resume];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"com.shrtlist.snapfresh" code:99 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Invalid coordinate"}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFarmersMarketsDidNotLoadNotification object:error];
    }
}

- (void)sendFarmersMarketDetailRequest:(NSArray *)marketIDs completionHandler:(void (^)(NSArray *farmersMarkets, NSError *error))completionHandler
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:marketIDs.count];
    
    [marketIDs enumerateObjectsUsingBlock:^(id x, NSUInteger index, BOOL *stop) {

        NSDictionary *farmersMarketDictionary = (NSDictionary *)x;
        NSString *farmersMarketID = farmersMarketDictionary[@"id"];
        NSString *farmersMarketName = farmersMarketDictionary[@"marketname"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@id=%@", kUSDABaseURL, kUSDAFarmersMarketDetailEndpoint, farmersMarketID];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error)
                                                    {
                                                        completionHandler(nil, error);
                                                    }
                                                    else
                                                    {
                                                        NSError *localError = nil;
                                                        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];

                                                        FarmersMarket *farmersMarket = [[FarmersMarket alloc] initWithDictionary:jsonDictionary];

                                                        if (CLLocationCoordinate2DIsValid(farmersMarket.coordinate))
                                                        {
                                                            farmersMarket.marketName = farmersMarketName;
                                                            
                                                            [tmpArray addObject:farmersMarket];
                                                            
                                                            if (index+1 == marketIDs.count)
                                                            {
                                                                completionHandler(tmpArray, nil);
                                                            }
                                                        }
                                                    }
                                                }];
        
        [task resume];
    }];
}

#pragma mark - Parse the JSON response

- (NSArray *)snapRetailersFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil)
    {
        *error = localError;
        return nil;
    }
    
    // Get the JSON array of retailers
    NSArray *retailersJSON = [jsonDictionary objectForKey:@"retailers"];
    
    NSMutableArray *retailerArray = [NSMutableArray arrayWithCapacity:retailersJSON.count];
    
    for (NSDictionary *retailerJSON in retailersJSON)
    {
        // Get the JSON dictionary of a retailer
        NSDictionary *retailerDictionary = [retailerJSON objectForKey:@"retailer"];
        SnapRetailer *retailer = [[SnapRetailer alloc] initWithDictionary:retailerDictionary];
        [retailerArray addObject:retailer];
    }
    
    return [NSArray arrayWithArray:retailerArray];
}

@end
