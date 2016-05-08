//
//  RutaViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import CoreData

class RutaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var contexto: NSManagedObjectContext? = nil

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var btnFoto: UIButton!
    @IBOutlet weak var btnCarrete: UIButton!
    @IBOutlet weak var imgFoto: UIImageView!
    
    private let miPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera){
            btnFoto.enabled = false
            btnCarrete.enabled = false
        }
        miPicker.delegate = self
        
        // Index de Campos de texto
        txtNombre.delegate = self
        txtNombre.tag = 0
        
        txtDescripcion.delegate = self
        txtDescripcion.tag = 1
        txtDescripcion.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        txtDescripcion.layer.borderWidth = 1.0
        txtDescripcion.layer.cornerRadius = 5
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        // Try to find next responder
        if let nextResponder: UIResponder! = textField.superview!.viewWithTag(nextTag){
            nextResponder.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func guardarRuta(sender: UIButton) {
        if txtNombre.text != nil && txtNombre.text != "" {
            //guardado en coleccion
            let ruta: Ruta = Ruta()
            ruta.nombre = txtNombre.text!
            ruta.descripcion = txtDescripcion.text!
            ruta.rutaID = DeViaje.rutas.count + 1
            ruta.foto = imgFoto.image
            ruta.lugares = []
            DeViaje.rutas.append(ruta)
            
            //guardado en coredata
            let nuevaRuta = NSEntityDescription.insertNewObjectForEntityForName("Ruta", inManagedObjectContext: self.contexto!)
            nuevaRuta.setValue(ruta.rutaID, forKey: "rutaID")
            nuevaRuta.setValue(txtNombre.text!, forKey: "nombre")
            nuevaRuta.setValue(txtDescripcion.text!, forKey: "descripcion")
            if imgFoto.image != nil {
                nuevaRuta.setValue(UIImagePNGRepresentation(imgFoto.image!), forKey: "foto")
            }
            do {
                try self.contexto?.save()
            }
            catch {
                
            }
            
            DeViaje.rutaSeleccionada = ruta.rutaID
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelarRuta(sender: UIButton) {
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
