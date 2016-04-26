//
//  MapViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import WatchConnectivity
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, WCSessionDelegate {

    @IBOutlet weak var mapaRuta: MKMapView!
    @IBOutlet weak var btnRutas: UIBarButtonItem!
    
    let manejador = CLLocationManager()
    private var origen: MKMapItem?
    private var destino: MKMapItem!
    var session : WCSession?
    
    override func viewWillAppear(animated: Bool) {
        if DeViaje.rutaSeleccionada != nil {
            cargarRuta()
        }
        if DeViaje.rutas.count > 0 {
            btnRutas.enabled = true
        } else {
            btnRutas.enabled = false
        }
        //enviar las rutas al watch
        if DeViaje.rutas.count > 0 {
            do {
                //convertir a rutas sin imágenes
                var rutasWK: [String] = []
                var rutaWK: String = ""
                /*var rutaWK: String = "0|Elige la Ruta"
                rutasWK.append(rutaWK)*/
                for ruta in DeViaje.rutas{
                    rutaWK = String(ruta.rutaID) + "|" + ruta.nombre + "|"
                    for lugar in ruta.lugares{
                        if(rutaWK.containsString("/")){
                            rutaWK += ","
                        }
                        rutaWK += String(lugar.latitud) + "/" + String(lugar.longitud)
                    }
                    rutasWK.append(rutaWK)
                }
                
                try session?.updateApplicationContext(
                    ["rutas" : rutasWK]
                )
            } catch let error as NSError {
                NSLog("Updating the context failed: " + error.localizedDescription)
            }
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapaRuta.delegate = self

        // Do any additional setup after loading the view.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
        //sesión de conectividad con watch
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        mapaRuta.centerCoordinate = mapaRuta.userLocation.coordinate
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapaRuta.showsUserLocation = true
        } else {
            manejador.stopUpdatingLocation()
            mapaRuta.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DeViaje.ubicacionActual = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: DeViaje.ubicacionActual!.coordinate.latitude, longitude: DeViaje.ubicacionActual!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapaRuta.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "ERROR", message: "error \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction(title: "OK", style: .Default, handler: { accion in
            //..
        })
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func capturarLugar(sender: UIBarButtonItem) {
        if DeViaje.rutaSeleccionada == nil{
            let alerta = UIAlertController(title: "ERROR", message: "Para capturar un lugar, primero debes seleccionar la ruta a la cual deseas agregarlo. Haz clic en rutas y selecciona una ruta o crea una nueva.", preferredStyle: .Alert)
            let accionOK = UIAlertAction(title: "OK", style: .Default, handler: { accion in
                //..
            })
            alerta.addAction(accionOK)
            self.presentViewController(alerta, animated: true, completion: nil)

        } else {
            //abrir formulario de captura de lugar
            let navc = self.navigationController
            navc?.performSegueWithIdentifier("capturaLugar", sender: self)
        }
    }
    
    func cargarRuta() {
        for ruta in DeViaje.rutas {
            if ruta.rutaID == DeViaje.rutaSeleccionada {
                origen = nil
                self.title = ruta.nombre
                
                //cargar pines
                for lugar in ruta.lugares {
                    let puntoCoor = CLLocationCoordinate2D(latitude: lugar.latitud, longitude: lugar.longitud)
                    let puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                    destino = MKMapItem(placemark: puntoLugar)
                    destino.name = lugar.nombre
                    crearPin(destino)
                    
                    if origen != nil {
                        obtenerRuta(origen!, destino: destino)
                    }
                    
                    origen = MKMapItem(placemark: puntoLugar)
                    origen!.name = lugar.nombre
                }
            }
        }
    }
    
    func crearPin(punto:MKMapItem) {
        let anota = MKPointAnnotation()
        anota.coordinate = punto.placemark.coordinate
        anota.title = punto.name
        mapaRuta.addAnnotation(anota)
    }
    
    func obtenerRuta(origen: MKMapItem, destino: MKMapItem) {
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
