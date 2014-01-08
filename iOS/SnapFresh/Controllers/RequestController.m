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
#import "AFNetworking.h"

@implementation RequestController

#pragma mark - Send SnapFresh request

- (void)sendRequestForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?address=%@", kSnapFreshBaseURL, kSnapFreshEndpoint, coordinateString];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];

    AFJSONResponseSerializer *jsonResponseSerializer = [[AFJSONResponseSerializer alloc] init];
    jsonResponseSerializer.readingOptions = NSJSONReadingAllowFragments;
    requestManager.responseSerializer = jsonResponseSerializer;

    [requestManager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *snapRetailers = [self snapRetailersFromJSONDictionary:responseObject];
        [self.delegate snapRetailersDidLoad:snapRetailers];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate snapRetailersDidNotLoadWithError:error];
    }];
}

#pragma mark - Parse the JSON response

- (NSArray *)snapRetailersFromJSONDictionary:(NSDictionary *)jsonDictionary
{
    // Get the JSON array of retailers
    NSArray *retailersJSON = [jsonDictionary valueForKey:@"retailers"];
    
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
