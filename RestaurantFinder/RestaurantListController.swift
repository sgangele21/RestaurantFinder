//
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/4/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import MapKit

class RestaurantListController: UITableViewController, MKMapViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    var coordinate: Coordinate?
    let foursquareClient = FoursquareClient(clientID: "0HKAKL2WZGTEP5USPTI4A1UN0LKPYX5PWAMJ0ZB24U02B0VY", clientSecret: "IRPL5JWVOAJXRV1OMOOQ0JR1I1DWMLAZ3O1A1EL3TASCZRFR")
    var venues: [Venue] = [] {
        didSet {
            self.tableView.reloadData()
            self.addMapAnnotations()
        }
    }
    let manager = LocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    var touch = UITouch()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search bar configuration
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        self.stackView.addSubview(self.searchController.searchBar)
        
        self.manager.getPermission()
        self.manager.onLocationFix = { [weak self] coordinate in
            self?.coordinate = coordinate
            self?.foursquareClient.fetchRestaurantsFor(coordinate, category: .food(nil)) { result in
                switch result {
                case .success(let venues):
                    self?.venues = venues
                case .failure(let error as NSError):
                    print(error)
                default:
                    break
                }
                
            }
        }
        
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                let venue = self.venues[indexPath.row]
                controller.venue = venue
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        let venue = self.venues[indexPath.row]
        cell.restaurantTitleLabel.text = venue.name
        cell.restaurantCheckinLabel.text = venue.checkins.description
        cell.restaurantCategoryLabel.text = venue.categoryName
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    @IBAction func refreshRestaurantData(_ sender: AnyObject) {
        if let coordinate = coordinate {
            foursquareClient.fetchRestaurantsFor(coordinate, category: .food(nil)) { result in
                switch result {
                case .success(let venues):
                    self.venues = venues
                case .failure(let error as NSError):
                    print(error)
                default:
                    break
                }
                
            }
        }
        
        self.refreshControl?.endRefreshing()

    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.01
        region.span.latitudeDelta = 0.01
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func addMapAnnotations() {
        removeAnnotations()
        if venues.count > 0 {
            let annotations: [MKPointAnnotation] = venues.map { venue in
                let point = MKPointAnnotation()
                
                if let coordinate = venue.location?.coordinate {
                    point.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    point.title = venue.name
                }
                return point
                
            }
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func removeAnnotations() {
        if mapView.annotations.count != 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        if coordinate != nil {
            foursquareClient.fetchRestaurantsFor(coordinate!, category: .food(nil), query: searchController.searchBar.text, searchRadius: nil, limit: nil) { result in
                switch result {
                case .success(let venues):
                    self.venues = venues
                case .failure(let error as NSError):
                    print(error)
                default:
                    break
                }
                
            }
                
            
        }
    }
    
}

