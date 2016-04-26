//
//  MapInterfaceController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 25/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import WatchKit
import Foundation
import MapKit
import CoreLocation

class MapInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var mapaRuta: WKInterfaceMap!
    
    let manejador = CLLocationManager()
    private var origen: MKMapItem?
    private var destino: MKMapItem!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if DeViaje.rutaSeleccionada != nil {
            cargarRuta()
        }

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func cargarRuta() {
        for ruta in DeViaje.rutas {
            if ruta.rutaID == DeViaje.rutaSeleccionada {
                origen = nil
                setTitle(ruta.nombre)
                
                //cargar pines
                for lugar in ruta.lugares {
                    let puntoCoor = CLLocationCoordinate2D(latitude: lugar.latitud, longitude: lugar.longitud)
                    let puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                    destino = MKMapItem(placemark: puntoLugar)
                    destino.name = lugar.nombre
                    crearPin(puntoLugar)
                    
                    if origen != nil {
                        //obtenerRuta(origen!, destino: destino)
                    }
                    
                    origen = MKMapItem(placemark: puntoLugar)
                    origen!.name = lugar.nombre
                }
            }
        }
    }
    
    func crearPin(punto:MKPlacemark) {
        let anota = CLLocationCoordinate2DMake(punto.coordinate.latitude, punto.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(anota, span)
        mapaRuta.setRegion(region)
        mapaRuta.addAnnotation(anota, withPinColor: .Red)
    }
    
    /*func obtenerRuta(origen: MKMapItem, destino: MKMapItem) {
        
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .Walking
        let indicaciones = MKDirections(request: solicitud)
        indicaciones.calculateDirectionsWithCompletionHandler({
            (respuesta: MKDirectionsResponse?, error: NSError?) in
            if error != nil {
                print("Error al obtener la ruta")
            } else {
                self.muestraRuta(respuesta!)
            }
        })
    }
    
    func muestraRuta(respuesta: MKDirectionsResponse) {
        for ruta in respuesta.routes {
            mapaRuta.addOverlay(ruta.polyline, level: MKOverlayLevel.AboveRoads)
            for paso in ruta.steps {
                print(paso.instructions)
            }
        }
        let centro = origen!.placemark.coordinate
        let region = MKCoordinateRegionMakeWithDistance(centro,3000,3000)
        mapaRuta.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }*/

}
