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
    let locationManager = CLLocationManager()
    var bars = [Bar]();
    var selectedBar = Bar();
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
        
        self.mapView.delegate = self
        
        locationSearchTable?.mapView = mapView
        locationSearchTable?.search = searchBar
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        loadJsonData();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //annotation onclick NOT WORKING
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation { return nil }
//
//        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") {
//            annotationView.annotation = annotation
//            print(" yeet" )
//            return annotationView
//        } else {
//            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"annotation")
//            print(" yeet again i guess")
//            annotationView.isEnabled = true
//            annotationView.canShowCallout = true
//
//            let btn = UIButton(type: .detailDisclosure)
//            annotationView.rightCalloutAccessoryView = btn
//            return annotationView
//        }
//    }
    
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
        DestScreen.name = selectedBar.name;
        DestScreen.beer = selectedBar.popularBeer;
        DestScreen.opentime = selectedBar.openingTime;
        DestScreen.closetime = selectedBar.openingTime;
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

