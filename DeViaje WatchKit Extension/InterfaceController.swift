//
//  InterfaceController.swift
//  DeViaje WatchKit Extension
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var wkipRutas: WKInterfacePicker!
    var session : WCSession?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
        
        setPickerItems()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func elegirRuta(value: Int) {
        DeViaje.rutaSeleccionada = DeViaje.rutas[value].rutaID
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]){
        let rutasWK: [String] = applicationContext["rutas"] as! [String]
        for ruta in rutasWK {
            let rutaArray = ruta.characters.split{$0 == "|"}.map(String.init)
            let rutaWK: Ruta = Ruta()
            rutaWK.rutaID = Int(rutaArray[0])!
            rutaWK.nombre = rutaArray[1]
            if rutaArray.count > 2 {
                let lugares: [String] = rutaArray[2].characters.split{$0 == ","}.map(String.init)
                let lugarWK: Lugar = Lugar()
                for lugar in lugares {
                    var coordenadas: [String] = lugar.characters.split{$0 == "/"}.map(String.init)
                    lugarWK.latitud = Double(coordenadas[0])!
                    lugarWK.longitud = Double(coordenadas[1])!
                    rutaWK.lugares.append(lugarWK)
                }
            }
            var existe = false
            var i: Int = 0;
            for r in DeViaje.rutas{
                if r.rutaID == rutaWK.rutaID {
                    existe = true
                    DeViaje.rutas[i] = rutaWK
                }
                i += 1
            }
            
            if !existe {
                DeViaje.rutas.append(rutaWK)
            }
        }
        self.setPickerItems()
    }
    
    func setPickerItems(){
        wkipRutas.setItems(nil)
        let pickerItems: [WKPickerItem] = DeViaje.rutas.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0.nombre
            return pickerItem
        }
    
        wkipRutas.setItems(pickerItems)
        
        if DeViaje.rutas.count >= 1 {
            DeViaje.rutaSeleccionada = DeViaje.rutas[0].rutaID
        }
    }

}
