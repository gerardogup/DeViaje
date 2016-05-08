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
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, WCSessionDelegate, ARDataSource {

    @IBOutlet weak var mapaRuta: MKMapView!
    @IBOutlet weak var btnRutas: UIBarButtonItem!
    @IBOutlet weak var btnCompartir: UIBarButtonItem!
    @IBOutlet weak var btnLugar: UIBarButtonItem!
    @IBOutlet weak var btnCentrarMapa: UIButton!
    
    
    let manejador = CLLocationManager()
    private var origen: MKMapItem?
    private var destino: MKMapItem!
    var session : WCSession?
    
    var centradoEnUsuario = true;
    
    var contexto: NSManagedObjectContext? = nil
    
    override func viewWillAppear(animated: Bool) {
        if DeViaje.rutaSeleccionada != nil {
            btnCompartir.enabled = true
            //btnLugar.enabled = true
            btnCentrarMapa.hidden = false
            cargarRuta()
        } else {
            btnCompartir.enabled = false
            //btnLugar.enabled = false
            btnCentrarMapa.hidden = true
            let annotationsToRemove = mapaRuta.annotations.filter { $0 !== mapaRuta.userLocation }
            mapaRuta.removeAnnotations( annotationsToRemove )
        }
        if DeViaje.rutas.count > 0 {
            btnRutas.enabled = true
        } else {
            btnRutas.enabled = false
            self.title = "Mis Rutas"
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
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        mapaRuta.delegate = self
        
        // Cargar datos desde CoreLocation
        obtenerRutasDesdeCoreData()

        // Do any additional setup after loading the view.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
        // Sesión de conectividad con watch
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
    
    @IBAction func centrarMapa() {
        if centradoEnUsuario {
            btnCentrarMapa.setTitle("Centrar Mapa en Ubicación Actual", forState: UIControlState.Normal)
            centradoEnUsuario = false
            for ruta in DeViaje.rutas {
                if ruta.rutaID == DeViaje.rutaSeleccionada && ruta.lugares.count > 0 {
                    let center = CLLocationCoordinate2D(latitude: ruta.lugares[0].latitud, longitude: ruta.lugares[0].longitud)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                    self.mapaRuta.setRegion(region, animated: true)
                    manejador.stopUpdatingLocation()
                }
            }
        } else {
            btnCentrarMapa.setTitle("Centrar Mapa en Ruta", forState: UIControlState.Normal)
            centradoEnUsuario = true
            mapaRuta.centerCoordinate = mapaRuta.userLocation.coordinate
            manejador.startUpdatingLocation()
        }
    }
    
    
    func obtenerRutasDesdeCoreData(){
        let rutaEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.contexto!)
        let peticion = rutaEntidad?.managedObjectModel.fetchRequestTemplateForName("getRutas")
        do {
            let ColeccionDeRutas = try self.contexto?.executeFetchRequest(peticion!)
            for ruta in ColeccionDeRutas! {
                let nuevaRuta = Ruta()
                nuevaRuta.rutaID = ruta.valueForKey("rutaID") as! Int
                nuevaRuta.nombre = ruta.valueForKey("nombre") as! String
                nuevaRuta.descripcion = ruta.valueForKey("descripcion") as! String
                nuevaRuta.foto = nil
                if ruta.valueForKey("foto") != nil {
                    nuevaRuta.foto = UIImage(data: ruta.valueForKey("foto") as! NSData)
                }
                nuevaRuta.lugares = []
                for lugar in ruta.valueForKey("tiene") as! Set<NSObject> {
                    let nuevoLugar = Lugar()
                    nuevoLugar.nombre = lugar.valueForKey("nombre") as! String
                    nuevoLugar.descripcion = lugar.valueForKey("descripcion") as! String
                    nuevoLugar.latitud = lugar.valueForKey("latitud") as! Double
                    nuevoLugar.longitud = lugar.valueForKey("longitud") as! Double
                    nuevoLugar.foto = nil
                    if lugar.valueForKey("foto") != nil {
                        nuevoLugar.foto = UIImage(data: lugar.valueForKey("foto") as! NSData)
                    }
                    
                    nuevaRuta.lugares.append(nuevoLugar)
                }
                
                DeViaje.rutas.append(nuevaRuta)
            }
        } catch {
            
        }

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
    
    // Rutas
    
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
        let region = MKCoordinateRegionMakeWithDistance(centro,1000,1000)
        mapaRuta.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }
    
    //Compartir en Redes Sociales

    @IBAction func compartirRuta() {
        var textoFijo = "Estos son los lugares que he visitado hoy:"
        for ruta in DeViaje.rutas {
            if ruta.rutaID == DeViaje.rutaSeleccionada {
                for lugar in ruta.lugares {
                    textoFijo += "\r\n" + lugar.nombre
                }
            }
        }
        textoFijo += "\r\nDescarga DeViaje"
        if let miSitio = NSURL(string: "https://github.com/gerardogup/DeViaje.git") {
            let objetosParaCompartir = [textoFijo, miSitio]
            let actividadRD = UIActivityViewController(activityItems: objetosParaCompartir, applicationActivities: nil)
            self.presentViewController(actividadRD, animated: true,  completion: nil)
        }
    }
    
    // Realidad Aumentada
    
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let vista = TestAnnotationView()
        vista.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        vista.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
            return vista
    }
    
    @IBAction func iniciaRealidadAumentada() {
        iniciaRAG()
    }
    
    func iniciaRAG() {
        let puntosDeInteres = obtenerAnotaciones()
        
        let arViewController = ARViewController()
        arViewController.debugEnabled = true
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        
        arViewController.setAnnotations(puntosDeInteres)
        self.presentViewController(arViewController, animated: true, completion: nil)

    }
    
    private func obtenerAnotaciones() -> Array<ARAnnotation>
    {
        var anotaciones: [ARAnnotation] = []
        
        for ruta in DeViaje.rutas {
            if ruta.rutaID == DeViaje.rutaSeleccionada {
                for lugar in ruta.lugares {
                    let anotacion = ARAnnotation()
                    anotacion.location = CLLocation(latitude: lugar.latitud, longitude: lugar.longitud)
                    anotacion.title = lugar.nombre
                    anotaciones.append(anotacion)
                }
            }
        }
        
        return anotaciones
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
