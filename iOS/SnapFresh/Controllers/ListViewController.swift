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

import MapKit

/*!
@class ListViewController
@abstract
Presents SNAP retailers and farmers markets in a table view
*/
class ListViewController: UITableViewController {

    // MARK: Public property
    
    var mapViewController: MapViewController?

    // MARK: Private properties
    
    private var retailers: [SnapRetailer] = []
    private var farmersMarkets: [FarmersMarket] = []
    
    // MARK: Deinitialization
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: View controller overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Retailers", comment: "Retailers")
        
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "snapRetailersDidLoad:", name: Constants.kSNAPRetailersDidLoadNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "farmersMarketsDidLoad:", name:Constants.kFarmersMarketsDidLoadNotification, object:nil)

        if (!UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)) {
            let snapLogo = UIImage(named: "snaplogo")
            navigationItem.titleView = UIImageView(image: snapLogo)
        }
    }
    
    // MARK: Public methods
    
    func snapRetailersDidLoad(notification: NSNotification) {
        retailers = notification.object as! [SnapRetailer]
        
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            // Reload the data when there are new annotations on the map.
            self.tableView.reloadData()
        }))
    }
    
    func farmersMarketsDidLoad(notification: NSNotification) {
        farmersMarkets = notification.object as! [FarmersMarket]
        
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: {
            // Reload the data when there are new annotations on the map.
            self.tableView.reloadData()
        }))
    }
    
    // MARK: Private method
    
    private func placemarkForIndexPath(indexPath: NSIndexPath) -> MKPlacemark? {
        let section = indexPath.section
        
        var placemark: MKPlacemark?
        
        if (section == 0) {
            placemark = retailers[indexPath.row]
        }
        else if (section == 1) {
            placemark = farmersMarkets[indexPath.row]
        }
        
        return placemark
    }

    // MARK: UITableViewDataSource protocol conformance

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleForSectionHeader: String?
        if (section == 0) {
            titleForSectionHeader = NSLocalizedString("Retailers", comment: "Retailers")
        }
        else if (section == 1) {
            titleForSectionHeader = NSLocalizedString("Farmers Markets", comment: "Farmers Markets")
        }
        
        return titleForSectionHeader
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if (section == 0) {
            numberOfRows = retailers.count;
        }
        else if (section == 1) {
            numberOfRows = farmersMarkets.count;
        }

        return numberOfRows
    }

    // Customize the appearance of table view cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let placemark = placemarkForIndexPath(indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = placemark?.title
        cell.detailTextLabel?.text = placemark?.subtitle
        
        return cell
    }

    // MARK: UITableViewDelegate protocol conformance

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let placemark = placemarkForIndexPath(indexPath)
        
        mapViewController?.didSelectRetailer(placemark!)
    }
}
