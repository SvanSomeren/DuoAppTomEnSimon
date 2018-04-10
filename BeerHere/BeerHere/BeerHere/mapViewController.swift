//
//  mapViewController.swift
//  BeerHere
//
//  Created by Fhict on 23/03/2018.
//  Copyright © 2018 issd. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

class mapViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    let annotationCircle = MKCircle();
    let userLocation = MKUserLocation();
    let locationManager = CLLocationManager()
    var bars = [Bar]();
    var selectedBar = Bar();
    let userLoc = MKPointAnnotation();
    var locationSearchTable: LocationSearchTable? = nil
    
    var resultSearchController:UISearchController? = nil
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Bars or Beers"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable?.mapView = mapView
        locationSearchTable?.search = searchBar
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true;
        
        LocationApi.setup(self)
        userLoc.coordinate = LocationApi.getCurrentLocation().coordinate
        userLoc.title = "You"
        mapView.addAnnotation(userLoc)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(userLoc.coordinate, CLLocationDistance(7000), CLLocationDistance(7000)), animated: true)

        loadJsonData();
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title
        {
            for bar in bars
            {
                if bar.name == (view.annotation?.title)!
                {
                    selectedBar = bar;
                }
            }
        }
        showRouteOnMap(pickupCoordinate: userLoc.coordinate, destinationCoordinate: (view.annotation?.coordinate)!)
        performSegue(withIdentifier: "infoSegue", sender: nil)
    }
    
    func loadJsonData()
    {
        let url = NSURL(string: "https://i360089.venus.fhict.nl/barren.json")
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            do
            {
                if (error == nil)
                {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    self.parseJsonData(rawData: jsonObject) // Will be explained later
                    
                }
                else
                {
                    print("Error with http request")
                    print(error.debugDescription)
                }
            }
            catch
            {
                print("\(error)")
                print("Error serializing JSON data")
            }
        }
        dataTask.resume();
    }
    
    func parseJsonData(rawData:Any)
    {
        if let jsonArray = rawData as? [[String:Any]]
        {
            for jsonDict in jsonArray
            {
                let newBar = Bar()
                if let name = jsonDict["name"] as? String
                {
                    newBar.name = name
                }
                if let lat = jsonDict["lat"] as? String
                {
                    newBar.lat = (lat as NSString).doubleValue
                }
                if let long = jsonDict["long"] as? String
                {
                    newBar.long = (long as NSString).doubleValue
                }
                if let openingTime = jsonDict["openingstime"] as? String
                {
                    newBar.openingTime = openingTime
                }
                if let closingTime = jsonDict["closingtime"] as? String{
                    newBar.closingTime = closingTime
                }
                if let popularBeer = jsonDict["popularbeer"] as? String{
                    newBar.popularBeer = popularBeer
                }
                if let website = jsonDict["website"] as? String{
                    newBar.website = website
                }
                print(newBar.name!);
                bars.append(newBar);
            }
            locationSearchTable?.bars = bars;
        }
        for bar in bars{
            let annotation = MKPointAnnotation();
            annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!)
            annotation.title = bar.name!
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DestScreen : infoViewController = segue.destination as! infoViewController
        DestScreen.name = selectedBar.name!;
        DestScreen.beer = selectedBar.popularBeer!;
        DestScreen.opentime = selectedBar.openingTime!;
        DestScreen.closetime = selectedBar.closingTime!;
        DestScreen.website = selectedBar.website!;
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
    
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    
        let sourceAnnotation = MKPointAnnotation()
    
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
    
        let destinationAnnotation = MKPointAnnotation()
    
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
    
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
    
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
    // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
        }
    
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

