//
//  EventoTableViewCell.swift
//  DeViaje
//
//  Created by Gerardo Guerra Pulido on 07/05/16.
//  Copyright © 2016 Gerardo Guerra Pulido. All rights reserved.
//

import UIKit

class EventoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHora: UILabel!
    @IBOutlet weak var lblEvento: UILabel!
    @IBOutlet weak var lblDescripcion: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
