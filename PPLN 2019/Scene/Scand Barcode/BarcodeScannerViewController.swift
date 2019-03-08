//
//  BarcodeScannerViewController.swift
//  PPLN 2019
//
//  Created by Robihamanto on 05/03/19.
//  Copyright © 2019 Robihamanto. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class BarcodeScannerViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var flag = ""
    var latestBarcode = ""
    var mailBarcode = ""
    var posBarcode = ""
    var isMailBarcodeScanned = false
    
    var suratSuara = [Any]()
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        makeNavBarTransparent()

        guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            showAlertController(withTitle: "Perhatian", andDescription: "Gagal mengakses kamera dari iPhone anda.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: cameraDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession.startRunning()
        view.bringSubviewToFront(messageLabel)
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func makeNavBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SuratSuara")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            self.suratSuara = result
        } catch {
            print("Failed to read data")
        }
    }
    
    func isBarcodeRecordedBefore(withBarcode code: String) -> Bool {
        fetchData()
        var isExist = false
        
        if suratSuara.count == 0 {
            isExist = false
        }
        
        for surat in suratSuara {
            let info = surat as! SuratSuara
            let barcode = info.barcode
            if code == barcode {
                isExist = true
                break
            } else {
                isExist = false
            }
        }
        return isExist
    }
    
    func isBarcodePosRecordedBefore(withBarcode code: String) -> Bool {
        fetchData()
        var isExist = false
        
        if suratSuara.count == 0 {
            isExist = false
        }
        
        for surat in suratSuara {
            let info = surat as! SuratSuara
            let barcode = info.barcodePos
            if code == barcode {
                isExist = true
                break
            } else {
                isExist = false
            }
        }
        return isExist
    }
    
    
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Tidak ada barcode yang terdeteksi"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                handleBarcode(barcode: metadataObj.stringValue!)
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
    func handleBarcode(barcode: String) {
        
        if latestBarcode == barcode {
            return
        } else if isMailBarcodeScanned == false {
            showAlertController(withTitle: "Barcode Surat Suara Terbaca", andDescription: "Sekarang Scan Barcode Dari Kantor POS")
            mailBarcode = barcode
            latestBarcode = barcode
            isMailBarcodeScanned = true
        } else {
            
            if barcode.contains("POS") {
                showAlertController(withTitle: "Barcode Surat Suara Terbaca", andDescription: "Sekarang Scan Barcode Dari Kantor POS")
                mailBarcode = barcode
                latestBarcode = barcode
                return
            }
            if presentedViewController != nil {
                return
            }
            
            posBarcode = barcode
            
            let isPosBarcodeScanned = isBarcodePosRecordedBefore(withBarcode: posBarcode)
            if isPosBarcodeScanned == true {
                showAlertController(withTitle: "Perhatian", andDescription: "Barcode pos sudah pernah terbaca sebelumnya, mohon periksa kembali barcode surat pos")
            }
            
            
            let alertPrompt = UIAlertController(title: "Barcode Terbaca", message: "Apakah status surat suara dengan nomor surat \(mailBarcode) dan nomor pos \(posBarcode) ingin anda simpan?", preferredStyle: .actionSheet)
            let sentAction = UIAlertAction(title: "Terkirim", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.saveBarcode(forMailCode: self.mailBarcode, forPosCode: self.posBarcode, andStatus: "terkirim")
            })
            let acceptedAction = UIAlertAction(title: "Diterima", style: UIAlertAction.Style.default, handler: { (action) -> Void in
                self.updateStatusBarcode(withBarcode: barcode, andStatus: "diterima")
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            
            if flag == "sent" {
                alertPrompt.addAction(sentAction)
            } else {
                alertPrompt.addAction(acceptedAction)
            }
            alertPrompt.addAction(cancelAction)
            
            fetchData()
            latestBarcode = barcode
            present(alertPrompt, animated: true, completion: nil)
        }
        
        
    }
    
    
    func saveBarcode(forMailCode mailCode: String, forPosCode posCode: String, andStatus status: String) {
        
        let isBarcodeScanned = isBarcodeRecordedBefore(withBarcode: mailCode)
        if isBarcodeScanned == true {
            updateStatusBarcode(withBarcode: mailCode, andStatus: status)
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SuratSuara", in: context)
        let newData = NSManagedObject(entity: entity!, insertInto: context)
        
        newData.setValue(getCurrentTime(), forKey: "sent")
        newData.setValue(" ", forKey: "accepted")
        newData.setValue(mailCode, forKey: "barcode")
        newData.setValue(posCode, forKey: "barcodePos")
        newData.setValue(status, forKey: "status")
        
        do {
            try context.save()
            self.showAlertController(withTitle: "Sukses", andDescription: "Surat suara terkirim")
            isMailBarcodeScanned = false //
        } catch {
            self.showAlertController(withTitle: "Perhatian", andDescription: "Gagal Menyimpan Data")
        }
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
            objectBarcode.setValue(getCurrentTime(), forKey: "accepted")
            do {
                try context.save()
                
                if status == "terkirim" {
                    self.showAlertController(withTitle: "Sukses", andDescription: "Surat suara terkirim")
                } else {
                    self.showAlertController(withTitle: "Sukses", andDescription: "Surat suara diterima")
                }
                
            } catch  {
                print(error)
                self.showAlertController(withTitle: "Perhatian", andDescription: "Gagal Menyimpan Data")
            }
        } catch {
            print(error)
            self.showAlertController(withTitle: "Perhatian", andDescription: "Gagal Menyimpan Data")
        }
    }
}
