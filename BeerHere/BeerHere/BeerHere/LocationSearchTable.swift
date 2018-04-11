
import UIKit
import MapKit
class LocationSearchTable : UITableViewController {
    var mapView: MKMapView? = nil
    var search: UISearchBar? = nil
    var bars: [Bar]? = nil
    var resultBars = [Bar]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultBars.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let bar = resultBars[indexPath.row];
        cell.textLabel?.text = bar.name;
        cell.detailTextLabel?.text = bar.popularBeer;
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBar = resultBars[indexPath.row]
        search?.text = selectedBar.name;
        dismiss(animated: true, completion: nil);
        print(selectedBar.name!);
        let annotation = MKPointAnnotation();
        annotation.coordinate = CLLocationCoordinate2D(latitude: selectedBar.lat!, longitude: selectedBar.long!);
        annotation.title = selectedBar.name;
        mapView?.addAnnotation(annotation);
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //look for text in the api call, then show markers for the ones where the search = api result
        resultBars.removeAll();
        let stringValue = search?.text;
        for bar in bars!{
            if bar.name?.lowercased().range(of: stringValue!.lowercased()) != nil
            {
                resultBars.append(bar);
            }
            else if bar.popularBeer?.lowercased().range(of: stringValue!.lowercased()) != nil
            {
                resultBars.append(bar);
            }
        }
        self.tableView.reloadData();
        let allAnnotations = mapView?.annotations;
        mapView?.removeAnnotations(allAnnotations!);
        if resultBars.isEmpty
        {
            for bar in bars!
            {
                let annotation = MKPointAnnotation();
                annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!);
                annotation.title = bar.name;
                mapView?.addAnnotation(annotation);
            }
        }
        let userLoc = MKPointAnnotation()
        userLoc.coordinate = LocationApi.getCurrentLocation().coordinate
        userLoc.title = "You"
        mapView?.addAnnotation(userLoc)
        mapView?.setRegion(MKCoordinateRegionMakeWithDistance(userLoc.coordinate, CLLocationDistance(7000), CLLocationDistance(7000)), animated: true)
        let overlays = mapView?.overlays
        mapView?.removeOverlays(overlays!)
    }
}
