/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
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

#import "ListViewController.h"
#import "RequestController.h"

@implementation ListViewController
{
    NSArray *_retailers;
    NSArray *_farmersMarkets;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snapRetailersDidLoad:) name:kSNAPRetailersDidLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(farmersMarketsDidLoad:) name:kFarmersMarketsDidLoadNotification object:nil];

    self.mapViewController = (MapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        UIImage *snapLogo = [UIImage imageNamed:@"snaplogo"];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:snapLogo];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource protocol conformance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleForSectionHeader = nil;
    if (section == 0)
    {
        titleForSectionHeader = NSLocalizedString(@"Retailers", @"Retailers");
    }
    else if (section == 1)
    {
        titleForSectionHeader = NSLocalizedString(@"Farmers Markets", @"Farmers Markets");
    }
    
    return titleForSectionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    if (section == 0)
    {
        numberOfRows = _retailers.count;
    }
    else if (section == 1)
    {
        numberOfRows = _farmersMarkets.count;
    }

    return numberOfRows;
}

// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger section = indexPath.section;
    
    MKPlacemark *placemark = nil;
    
    if (section == 0)
    {
        placemark = [_retailers objectAtIndex:indexPath.row];
    }
    else if (section == 1)
    {
        placemark = [_farmersMarkets objectAtIndex:indexPath.row];
    }

    cell.textLabel.text = placemark.title;
    cell.detailTextLabel.text = placemark.subtitle;
	
	return cell;
}

#pragma mark - UITableViewDelegate protocol conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    
    MKPlacemark *placemark = nil;
    
    if (section == 0)
    {
        placemark = [_retailers objectAtIndex:indexPath.row];
    }
    else if (section == 1)
    {
        placemark = [_farmersMarkets objectAtIndex:indexPath.row];
    }
    
    [self.mapViewController didSelectRetailer:placemark];
}

#pragma mark - NSNotification methods

- (void)snapRetailersDidLoad:(NSNotification *)notification
{
    _retailers = notification.object;
    
    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
        // Reload the data when there are new annotations on the map.
        [self.tableView reloadData];
    }]];
}

- (void)farmersMarketsDidLoad:(NSNotification *)notification
{
    _farmersMarkets = notification.object;

    [[NSOperationQueue mainQueue] addOperation:[ NSBlockOperation blockOperationWithBlock:^{
        // Reload the data when there are new annotations on the map.
        [self.tableView reloadData];
    }]];
}

@end
