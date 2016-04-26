//
//  LugarViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 25/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit

class LugarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var imgFoto: UIImageView!
    @IBOutlet weak var btnFoto: UIButton!
    @IBOutlet weak var btnCarrete: UIButton!
    
    
    private let miPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera){
            btnFoto.hidden = true
            btnCarrete.hidden = true
        }
        miPicker.delegate = self
        
        self.txtDescripcion.layer.borderWidth = 1
        let gris = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        self.txtDescripcion.layer.borderColor = gris.CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func guardarLugar(sender: UIButton) {
        let lugar = Lugar()
        lugar.nombre = txtNombre.text!
        lugar.descripcion = txtDescripcion.text
        lugar.foto = imgFoto.image
        lugar.latitud = DeViaje.ubicacionActual!.coordinate.latitude
        lugar.longitud = DeViaje.ubicacionActual!.coordinate.longitude
        for ruta in DeViaje.rutas {
            if(ruta.rutaID == DeViaje.rutaSeleccionada){
                ruta.lugares.append(lugar)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelarLugar(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ocultarTeclado(sender: UIControl) {
        txtNombre.resignFirstResponder()
        txtDescripcion.resignFirstResponder()
    }
    
    @IBAction func mostrarCamara(sender: UIButton) {
        miPicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(miPicker, animated:true, completion: nil)
    }
    
    @IBAction func mostrarCarrete(sender: UIButton) {
        miPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(miPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        imgFoto.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //funcion del protocolo para cuando el usuario cancela el picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
