//
//  OrganizeMailViewController.swift
//  PPLN 2019
//
//  Created by Robihamanto on 08/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit

class OrganizeMailViewController: UIViewController {
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    var flag = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        if flag == "sent" {
            listButton.setTitle("Surat Suara Terkirim", for: .normal)
        } else {
            listButton.setTitle("Surat Suara Diterima", for: .normal)
        }
        scanButton.layer.cornerRadius = 10
        listButton.layer.cornerRadius = 10
    }
    

    @IBAction func scanBarcode(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "BarcodeScannerViewController") as? BarcodeScannerViewController else { return }
        controller.flag = flag
        self.title = ""
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func listButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MailListViewController") as? MailListViewController else { return }
        controller.flag = flag
        self.title = ""
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
