//
//  BrowserViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {

    @IBOutlet weak var direccion: UILabel!
    @IBOutlet weak var web: UIWebView!
    
    var urls: String? = DeViaje.urlQR
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        direccion?.text = urls!
        let url = NSURL(string: urls!)
        let peticion = NSURLRequest(URL: url!)
        web.loadRequest(peticion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
