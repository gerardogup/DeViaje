//
//  NavigationViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit

class NavigationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation*/
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let origen = sender as! QRViewController
        let vc = segue.destinationViewController as! BrowserViewController
        origen.sesion?.stopRunning()
        vc.urls = origen.urls
    }

}
