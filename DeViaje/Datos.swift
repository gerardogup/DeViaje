//
//  Datos.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import CoreLocation

struct DeViaje{
    static var rutas: [Ruta] = []
    static var rutaSeleccionada: Int? = nil
    static var urlQR: String? = nil
    static var ubicacionActual: CLLocation? = nil
    static var eventos: [Evento] = []
}

class Ruta {
    var rutaID: Int = 0
    var nombre: String = ""
    var foto: UIImage? = nil
    var descripcion: String = ""
    var lugares: [Lugar] = []
}

class Lugar {
    var nombre: String = ""
    var descripcion: String = ""
    var foto: UIImage? = nil
    var latitud: Double = 0.0
    var longitud: Double = 0.0
}

class Evento {
    var fecha: String = ""
    var hora: String = ""
    var nombre: String = ""
    var descripcion: String = ""
}