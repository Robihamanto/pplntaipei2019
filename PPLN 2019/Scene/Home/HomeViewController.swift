//
//  HomeViewController.swift
//  PPLN 2019
//
//  Created by Robihamanto on 05/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "PPLN TAIPEI 2019"
    }
    
    func setupView() {
        sendButton.layer.cornerRadius = 20
        acceptButton.layer.cornerRadius = 20
        listButton.layer.cornerRadius = 20
    }
    
    
    @IBAction func sendBarcodeButtonDidTap(_ sender: Any) {
        navigateToScandBarcode(withFlag: "sent")
    }
    
    @IBAction func acceptBarcodeButtonDidTap(_ sender: Any) {
        navigateToScandBarcode(withFlag: "accept")
    }
    
    func navigateToScandBarcode(withFlag flag: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "OrganizeMailViewController") as? OrganizeMailViewController else { return }
        controller.flag = flag
        self.title = ""
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func listButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MailListViewController") as? MailListViewController else { return }
        self.title = ""
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
