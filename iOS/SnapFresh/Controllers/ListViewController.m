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

@interface ListViewController () // Class extension
@property (nonatomic, strong) NSArray *retailers;
@end

@implementation ListViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.mapViewController = (MapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Set ourselves as the mapViewController's delegate
    self.mapViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        UIImage *snapLogo = [UIImage imageNamed:@"snaplogo"];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:snapLogo];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    self.mapViewController.delegate = nil;
}

#pragma mark - UITableViewDataSource protocol conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.retailers.count;
}

// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SnapRetailer *retailer = [self.retailers objectAtIndex:indexPath.row];
    
    // Set the cell labels with SNAP retailer info
    cell.textLabel.text = retailer.name;
    cell.detailTextLabel.text = retailer.address;
	
	return cell;
}

#pragma mark - UITableViewDelegate protocol conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SnapRetailer *retailer = [self.retailers objectAtIndex:indexPath.row];
    
    [self.mapViewController didSelectRetailer:retailer];
}

#pragma mark - MapViewControllerDelegate protocol conformance

- (void)annotationsDidLoad:(NSArray *)retailers
{
    self.retailers = retailers;

    // Reload the data when there are new annotations on the map.
    [self.tableView reloadData];
}

@end
