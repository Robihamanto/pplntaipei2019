//
//  SuratSuaraCell.swift
//  PPLN 2019
//
//  Created by Robihamanto on 05/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit

class SuratSuaraCell: UITableViewCell {
    
    public static let identifier = "SuratSuaraCell"
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var barcodePOSLabel: UILabel!
    @IBOutlet weak var statusLabel: UIButton!
    
    func configure(with suratsuara: SuratSuara) {
        self.barcodeLabel.text = suratsuara.barcode
        self.barcodePOSLabel.text = suratsuara.barcodePos
        self.statusLabel.layer.cornerRadius = 5
        
        if suratsuara.status?.lowercased() == "terkirim" {
            self.statusLabel.setTitle("Terkirim", for: .normal)
            self.statusLabel.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else {
            self.statusLabel.setTitle("Diterima", for: .normal)
            self.statusLabel.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
    }
    
}
