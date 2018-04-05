
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
        print(resultBars.count)
        return resultBars.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let textstuff = resultBars[indexPath.row];
        cell.textLabel?.text = textstuff.name;
        return cell
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //look for text in the api call, then show markers for the ones where the search = api result
        resultBars.removeAll();
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
        self.tableView.reloadData();
        let allAnnotations = mapView?.annotations
        mapView?.removeAnnotations(allAnnotations!)
        if resultBars.isEmpty
        {
            for bar in bars!
            {
                let annotation = MKPointAnnotation();
                annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!)
                mapView?.addAnnotation(annotation)
            }
        }
        else{
            //misschien onderstaande code in selecteditem van tableview gooien
//            for bar in resultBars
//            {
//                print("L")
//                let annotation = MKPointAnnotation();
//                annotation.coordinate = CLLocationCoordinate2D(latitude: bar.lat!, longitude: bar.long!)
//                mapView?.addAnnotation(annotation)
//            }
            
            //code hieronder in een tableview override voor selecteditem gooien?
            let annotation = MKPointAnnotation();
            let selectedBar = resultBars[(tableView.indexPathForSelectedRow?.row)!]
            annotation.coordinate = CLLocationCoordinate2D(latitude: selectedBar.lat!, longitude: selectedBar.long!)
            mapView?.addAnnotation(annotation)
            dismiss(animated: true, completion: nil)
        }
        
    }
}
