//
//  DetailViewController.swift
//  iBanksUA
//
//  Created by Taras Pasichnyk on 5/28/16.
//  Copyright © 2016 Taras Pasichnyk. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var currenciesTableView: UITableView!
    @IBOutlet weak var banksMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currencies = [Currency]()
    
    var detailItem: JSON? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        let master = MasterViewController()
        
        if let detail = self.detailItem {
            master.allCurrencies { (result) in
                self.currencies = [Currency]()
                for currency in detail[JsonConst.bank.currencies] {
                    let newItem = Currency(newKey: currency.0, newName: result[currency.0].stringValue, newSellPrice: currency.1["ask"].stringValue, newBuyPrice: currency.1["bid"].stringValue)
                    self.currencies.append(newItem)
                }
            }
            
            master.allCities({ (result) in
                self.startSearchWithStringQuery("\(result[detail[JsonConst.bank.cityId].stringValue]), \(detail[JsonConst.bank.address])")
                
            })
            
            dispatch_async(dispatch_get_main_queue()) {
                self.currenciesTableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
    }
    
}

// MARK: Table View
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.KeysConstants.kCurrencyCellIdentifier, forIndexPath: indexPath) as! CurrencyCell
        let object = self.currencies[indexPath.row]
        cell.currencyName.text = object.name
        cell.sellPrice.text = object.sellPrice
        cell.buyPrice.text = object.buyPrice
        return cell
    }
    
}

// MARK: Segue
extension DetailViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kCompareRates {
            if let indexPath = self.currenciesTableView.indexPathForSelectedRow {
                let object = self.currencies[indexPath.row]
                let controller = segue.destinationViewController  as! ComparationViewController
                print("\(self.currencies[indexPath.row]) \(object)")
                controller.detailItem = object.key
            }
        }
    }
    
}

// MARK: Map Kit
extension DetailViewController: MKMapViewDelegate {
    
    func startSearchWithStringQuery(query: String) {
        self.locationManager.requestWhenInUseAuthorization()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        if let mapView = self.banksMapView {
            request.region = mapView.region
        }
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?,
            error: NSError?) in
            
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.banksMapView.addAnnotation(annotation)
                    self.createRouteBetween(annotation.coordinate, destination: (self.locationManager.location?.coordinate)!)
                }
            }
        })
    }
    
    func createRouteBetween(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.banksMapView.addOverlay(route.polyline)
                self.banksMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
        let from = MKPointAnnotation()
        from.coordinate = source
        let to = MKPointAnnotation()
        to.coordinate = destination
        
        let objects = [from, to]
        var allAnnMapRect = MKMapRectNull
        
        for object in objects {
            let thisAnnMapPoint = MKMapPointForCoordinate(object.coordinate)
            let thisAnnMapRect = MKMapRectMake(thisAnnMapPoint.x, thisAnnMapPoint.y, 1, 1)
            allAnnMapRect = MKMapRectUnion(allAnnMapRect, thisAnnMapRect)
        }
        
        let edgeInset = UIEdgeInsetsMake(50, 50, 50, 50)
        
        self.banksMapView.setVisibleMapRect(allAnnMapRect, edgePadding: edgeInset, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }
    
}

//MARK: Location Manager
extension DetailViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location = locations.last! as CLLocation
        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
//        self.banksMapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
}
