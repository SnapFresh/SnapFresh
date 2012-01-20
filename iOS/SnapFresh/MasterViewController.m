//
//  MasterViewController.m
//  SnapFresh
//
//  Created by Marco Abundo on 1/18/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SnapRetailer.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Set ourselves as the detailViewController's delegate
    self.detailViewController.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UITableViewDataSource conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return retailers.count;
}

// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SnapRetailer *retailer = [retailers objectAtIndex:indexPath.row];
    
    // Set the cell labels with SnapFresh retailer info
    cell.textLabel.text = retailer.name;
    cell.detailTextLabel.text = retailer.address;
	
	return cell;
}

#pragma mark - UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnapRetailer *retailer = [retailers objectAtIndex:indexPath.row];

    NSArray *selectedAnnotations = [NSArray arrayWithObject:retailer];
    
    MKMapView *mapView = self.detailViewController.mapView;
    
    [mapView setSelectedAnnotations:selectedAnnotations];
}

#pragma mark - DetailViewControllerDelegate conformance

- (void)annotationsDidLoad:(DetailViewController *)controller
{
    retailers = [self.detailViewController.mapView annotations];

    // Reload the data when there are new annotations on the map.
    [self.tableView reloadData];
}

@end
