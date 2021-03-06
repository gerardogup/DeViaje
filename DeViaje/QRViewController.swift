//
//  QRViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var sesion: AVCaptureSession?
    var capa: AVCaptureVideoPreviewLayer?
    var marcoQR: UIView?
    var urls: String?
    
    override func viewWillAppear(animated: Bool) {
        sesion?.startRunning()
        marcoQR?.frame = CGRectZero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let dispositivo = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let entrada = try AVCaptureDeviceInput(device: dispositivo)
            sesion = AVCaptureSession()
            sesion?.addInput(entrada)
            let metaDatos = AVCaptureMetadataOutput()
            sesion?.addOutput(metaDatos)
            metaDatos.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metaDatos.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            capa = AVCaptureVideoPreviewLayer(session: sesion!)
            capa?.videoGravity = AVLayerVideoGravityResizeAspectFill
            capa?.frame = view.layer.bounds
            view.layer.addSublayer(capa!)
            marcoQR = UIView()
            marcoQR?.layer.borderWidth = 3
            marcoQR?.layer.borderColor = UIColor.redColor().CGColor
            view.addSubview(marcoQR!)
            sesion?.startRunning()	
        }
        catch {
            
        }
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        marcoQR?.frame = CGRectZero
        if(metadataObjects == nil || metadataObjects.count == 0) {
            return
        }
        let objMetadato = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if(objMetadato.type == AVMetadataObjectTypeQRCode) {
            let objBordes = capa?.transformedMetadataObjectForMetadataObject(objMetadato as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            marcoQR?.frame = objBordes.bounds
            if (objMetadato.stringValue != nil) {
                self.urls = objMetadato.stringValue
                DeViaje.urlQR = self.urls
                sesion?.stopRunning()
                let navc = self.navigationController
                navc?.performSegueWithIdentifier("detalle", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}
