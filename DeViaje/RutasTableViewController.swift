//
//  RutasTableViewController.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 24/04/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit
import CoreData

class RutasTableViewController: UITableViewController {
    
    var contexto: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DeViaje.rutas.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RutaTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RutaTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let ruta = DeViaje.rutas[indexPath.row]
        
        cell.lblRutaNombre.text = ruta.nombre
        cell.imgRutaFoto.image = ruta.foto
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DeViaje.rutaSeleccionada = DeViaje.rutas[indexPath.item].rutaID
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let rutaEntidad = NSEntityDescription.entityForName("Ruta", inManagedObjectContext: self.contexto!)
            let peticion = rutaEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("getRuta", substitutionVariables: ["rutaID" : DeViaje.rutas[indexPath.item].rutaID])
            do {
                let rutaAEliminar = try self.contexto?.executeFetchRequest(peticion!)
                if rutaAEliminar?.count > 0 {
                    self.contexto?.deleteObject(rutaAEliminar![0] as! NSManagedObject)
                }
                try self.contexto?.save()
            }
            catch {
                
            }
            
            DeViaje.rutas.removeAtIndex(indexPath.item)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if(DeViaje.rutas.count == 0){
                self.dismissViewControllerAnimated(true, completion: nil)
                DeViaje.rutaSeleccionada = nil
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

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
