
import UIKit
import MapKit
class LocationSearchTable : UITableViewController {
    var mapView: MKMapView? = nil
    var search: UISearchBar? = nil
    var bars: [Bar]? = nil
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //look for text in the api call, then show markers for the ones where the search = api result
        var resultBars = [Bar]()
        let stringValue = search?.text
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
        let allAnnotations = mapView?.annotations
        mapView?.removeAnnotations(allAnnotations!)
        for bar in resultBars
        {
            let annotation = MKPointAnnotation();
            annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!)
            mapView?.addAnnotation(annotation)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}
