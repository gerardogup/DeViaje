//
//  EventosTableViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 07/05/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit

class EventosTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        cargarEventos()
        self.title = "Eventos CDMX"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeViaje.eventos.count
    }

    
    func cargarEventos(){
        let urls = "https://eplatfront.villagroup.com/privatelabel/getevents"
        let url = NSURL(string: urls)
        
        let datos = NSData(contentsOfURL: url!)
        if datos != nil {
            do {
                //let json1 = NSString(data:datos!, encoding: NSUTF8StringEncoding)
                //print(json1)
                
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                let eventos = json as! NSDictionary
                for evento in eventos["Eventos"] as! [[String: String]] {
                    let nuevoEvento = Evento()
                    nuevoEvento.fecha = evento["Fecha"]!
                    nuevoEvento.hora = evento["Hora"]!
                    nuevoEvento.nombre = evento["Nombre"]!
                    nuevoEvento.descripcion = evento["Descripcion"]!
                    DeViaje.eventos.append(nuevoEvento)
                }
            } catch _ {
                alertaDeError("Ha ocurrido un error con el origen de datos.")
            }
            
        } else {
            alertaDeError("Ha habido un error al tratar de obtener la información. Verifica tu conexión a internet.")
        }
    }
    
    func alertaDeError(mensaje: String){
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alerta.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            alerta.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alerta, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EventoTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventoTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let evento = DeViaje.eventos[indexPath.row]
        
        cell.lblFecha.text = evento.fecha
        cell.lblHora.text = evento.hora
        cell.lblEvento.text = evento.nombre
        cell.lblDescripcion.text = evento.descripcion
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
