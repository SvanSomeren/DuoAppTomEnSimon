//
//  infoViewController.swift
//  BeerHere
//
//  Created by Fhict on 23/03/2018.
//  Copyright © 2018 issd. All rights reserved.
//

import UIKit
import AVFoundation

class infoViewController: UIViewController {

    var player: AVAudioPlayer?
    
    @IBOutlet var namelabel: UILabel!
    @IBOutlet var beerlabel: UILabel!
    @IBOutlet var pricelabel: UILabel!
    @IBOutlet var openlabel: UILabel!
    @IBOutlet var closedlabel: UILabel!
    @IBOutlet var websitebutton: UIButton!
    @IBOutlet var startroutebutton: UIButton!
    
    @IBAction func startroutebutton(_ sender: Any) {
        playSound()
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func websitebutton(_ sender: Any) {
        if let url = NSURL(string:website){
            UIApplication.shared.openURL(url as URL)
        }
    }
    
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
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "pouring", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            print("played sound")
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
