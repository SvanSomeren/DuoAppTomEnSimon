//
//  infoViewController.swift
//  BeerHere
//
//  Created by Fhict on 23/03/2018.
//  Copyright © 2018 issd. All rights reserved.
//

import UIKit

class infoViewController: UIViewController {

    
    @IBOutlet var namelabel: UILabel!
    @IBOutlet var beerlabel: UILabel!
    @IBOutlet var pricelabel: UILabel!
    @IBOutlet var openlabel: UILabel!
    @IBOutlet var closedlabel: UILabel!
    @IBOutlet var websitebutton: UIButton!
    @IBOutlet var startroutebutton: UIButton!
    
    var name = String();
    var beer = String();
    var price = String();
    var opentime = String();
    var closetime = String();
    var website = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        namelabel.text = name;
        beerlabel.text = beer;
        pricelabel.text = price;
        openlabel.text = opentime;
        closedlabel.text = closetime;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
