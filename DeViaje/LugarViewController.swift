//
//  LugarViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 25/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import CoreData

class LugarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var contexto: NSManagedObjectContext? = nil

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var imgFoto: UIImageView!
    @IBOutlet weak var btnFoto: UIButton!
    @IBOutlet weak var btnCarrete: UIButton!
    
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
        
        //Index de Campos de texto
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
    
    @IBAction func guardarLugar(sender: UIButton) {
        if txtNombre.text != nil && txtNombre.text != "" {
            // Guardar en Colección
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
            
            // Guardar en CoreData
            let rutaEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.contexto!)
            let peticion = rutaEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("getRuta", substitutionVariables: ["rutaID" : DeViaje.rutaSeleccionada!])
            do {
                let rutaObtenida = try self.contexto?.executeFetchRequest(peticion!)
                for obj in rutaObtenida! {
                    obj.setValue(obtenerLugares(), forKey: "tiene")
                }
                try self.contexto?.save()
            }
            catch {
            }
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func obtenerLugares() -> Set<NSObject> {
        var lugaresEntidades = Set<NSObject>()
        
        for ruta in DeViaje.rutas {
            if ruta.rutaID == DeViaje.rutaSeleccionada {
                for lugar in ruta.lugares {
                    let otroLugar = NSEntityDescription.insertNewObjectForEntityForName("Lugar", inManagedObjectContext: self.contexto!)
                    otroLugar.setValue(lugar.nombre, forKey: "nombre")
                    otroLugar.setValue(lugar.descripcion, forKey: "descripcion")
                    otroLugar.setValue(lugar.latitud, forKey: "latitud")
                    otroLugar.setValue(lugar.longitud, forKey: "longitud")
                    if lugar.foto != nil {
                        otroLugar.setValue(UIImagePNGRepresentation(lugar.foto!), forKey: "foto")
                    }
                    
                    lugaresEntidades.insert(otroLugar)
                }
            }
        }
        
        let nuevoLugar = NSEntityDescription.insertNewObjectForEntityForName("Lugar", inManagedObjectContext: self.contexto!)
        nuevoLugar.setValue(txtNombre.text, forKey: "nombre")
        nuevoLugar.setValue(txtDescripcion.text, forKey: "descripcion")
        nuevoLugar.setValue(DeViaje.ubicacionActual!.coordinate.latitude, forKey: "latitud")
        nuevoLugar.setValue(DeViaje.ubicacionActual!.coordinate.longitude, forKey: "longitud")
        if imgFoto.image != nil {
            nuevoLugar.setValue(UIImagePNGRepresentation(imgFoto.image!), forKey: "foto")
        }

        lugaresEntidades.insert(nuevoLugar)

        return lugaresEntidades
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
