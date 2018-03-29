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

class mapViewController: UIViewController, CLLocationManagerDelegate {
    let annotationCircle = MKCircle();
    let locationManager = CLLocationManager()
    var bars = [Bar]();
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //annotation onclick
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            return annotationView
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
        }
        for bar in bars{
            let annotation = MKPointAnnotation();
            annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!)
            mapView.addAnnotation(annotation)
        }
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
