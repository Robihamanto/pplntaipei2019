//
//  MailListViewController.swift
//  PPLN 2019
//
//  Created by Robihamanto on 05/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit
import CoreData

class MailListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var suratSuara = [Any]()
    var filteredSuratSuara = [Any]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var flag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupTablView()
        setupSearchBar()
        fetchData()
        filterDataWithFlag()
    }
    
    func setupTitle() {
        if flag == "sent" {
            title = "Surat Suara Terkirim"
        } else if flag == "accept"  {
            title = "Surat Suara Diterima"
        } else {
            title = "Semua Data Surat Suara"
        }
    }
    
    func setupTablView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 45
        
        let nib = UINib(nibName: "SuratSuaraCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SuratSuaraCell.identifier)
    }
    
    func setupSearchBar() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Cari Barcode SuratSuara"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Semua", "Terkirim", "Diterima"]
        searchController.searchBar.delegate = self
    }
    
    func reloadData() {
        fetchData()
        filterDataWithFlag()
        tableView.reloadData()
    }
    
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SuratSuara")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            self.suratSuara = result
            self.tableView.reloadData()
        } catch {
            print("Failed to read data")
        }
    }
    
    func filterDataWithFlag() {
        if flag == "" { return }
        var status = "terkirim"
        if flag == "accept" {
            status = "diterima"
        }
        var data = [SuratSuara]()
        for surat in suratSuara {
            guard let info = surat as? SuratSuara else { return }
            if info.status == status {
                data.append(info)
            }
        }
        self.suratSuara = data
    }
    
    @IBAction func saveCSVFile() {
        
        let fileName = "SuratSuaraTerkirim-POS58.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Barcode Surat Suara,Barcode Kantor POS,Status,Terkirim Pada,Diterima Pada\n"
        
        let count = suratSuara.count
        if count > 0 {
            for suara in suratSuara {
                
                guard let info = suara as? SuratSuara else { return }
                guard let barcode = info.barcode else { return }
                guard let barcodePos = info.barcodePos else { return }
                guard let status = info.status else { return }
                guard let sent = info.sent else { return }
                guard let accepted = info.accepted else { return }
                
                let newLine = "\(barcode),\(barcodePos),\(status),\(sent),\(accepted)\n"
                csvText.append(contentsOf: newLine)
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            
        } else {
            showAlertController(withTitle: "Perhatian", andDescription: "Belum ada data yang bisa di export")
            print("There is no data to export")
        }
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSuratSuara = suratSuara.filter({ surat -> Bool in
            if searchBarIsEmpty() {
                return true
            } else {
                let info = surat as! SuratSuara
                return (info.barcode?.contains(searchText.lowercased()))!
            }
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
}

extension MailListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
        return self.filteredSuratSuara.count
        } else {
            return self.suratSuara.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SuratSuaraCell.identifier, for: indexPath) as? SuratSuaraCell else { return UITableViewCell()}
        if isFiltering() {
            cell.configure(with: filteredSuratSuara[indexPath.row] as! SuratSuara)
        } else {
            cell.configure(with: suratSuara[indexPath.row] as! SuratSuara)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = suratSuara[indexPath.row] as? SuratSuara else { return }
        
        let alertPrompt = UIAlertController(title: "Kelola Surat Suara", message: "kelola surat suara dengan barcode \(info.barcode ?? "")?", preferredStyle: .actionSheet)
        let sentAction = UIAlertAction(title: "Terkirim", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.updateStatusBarcode(withBarcode: info.barcode ?? "", andStatus: "terkirim")
        })
        
        let acceptedAction = UIAlertAction(title: "Diterima", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.updateStatusBarcode(withBarcode: info.barcode ?? "", andStatus: "diterima")
        })
        
        let deleteAction = UIAlertAction(title: "Hapus", style: UIAlertAction.Style.destructive, handler: { (action) -> Void in
            self.deleteBarcode(withBarcode: info.barcode ?? "", indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(sentAction)
        alertPrompt.addAction(acceptedAction)
        alertPrompt.addAction(deleteAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func updateStatusBarcode(withBarcode barcode: String, andStatus status: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "SuratSuara")
        fetchRequest.predicate = NSPredicate(format: "barcode = %@", barcode)
        
        do {
            let data = try context.fetch(fetchRequest)
            let objectBarcode = data[0] as! NSManagedObject
            objectBarcode.setValue(status, forKey: "status")
            
            if status == "terkirim" {
                objectBarcode.setValue(getCurrentTime(), forKey: "sent")
            } else {
                objectBarcode.setValue(getCurrentTime(), forKey: "accepted")
            }
            
            do {
                try context.save()
                self.showAlertController(withTitle: "Sukses", andDescription: "Surat suara diterima")
            } catch  {
                print(error)
            }
        } catch {
            print(error)
        }
        
        reloadData()
    }
    
    func deleteBarcode(withBarcode barcode: String, indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "SuratSuara")
        fetchRequest.predicate = NSPredicate(format: "barcode = %@", barcode)
        
        do {
            let data = try context.fetch(fetchRequest)
            let objectBarcode = data[0] as! NSManagedObject
            context.delete(objectBarcode)
            
            do {
                try context.save()
            } catch  {
                print(error)
            }
        } catch {
            print(error)
        }
        
        reloadData()
    }
    
    
}

extension MailListViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MailListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

