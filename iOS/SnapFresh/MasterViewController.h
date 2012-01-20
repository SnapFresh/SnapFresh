//
//  MasterViewController.h
//  SnapFresh
//
//  Created by Marco Abundo on 1/18/12.
//  Copyright (c) 2012 shrtlist.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface MasterViewController : UITableViewController <DetailViewControllerDelegate>
{
    NSArray *retailers;
}

@property (nonatomic, strong) DetailViewController *detailViewController;

@end
