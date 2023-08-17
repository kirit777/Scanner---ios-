//
//  ViewController.swift
//  ScannerDemo
//
//  Created by Kirit on 17/08/23.
//

import UIKit
import WeScan
import PDFKit

class ViewController: UIViewController {

    var documents = [URL]()
    var scannedImage: UIImage!
    var documentOrderNumber = 0
    
    @IBOutlet weak var imgPlaceholder: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickBtn(_ sender: Any) {
        let scannerVC = ImageScannerController()
        scannerVC.imageScannerDelegate = self
        scannerVC.modalPresentationStyle = .fullScreen
        present(scannerVC, animated: true, completion: nil)
    }
    
    func savePicture(picture: UIImage, imageName: String) {
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let data = picture.jpegData(compressionQuality: 0.9)
        FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
    }
    
    func showSaveDialog(scannedImage: UIImage) {
        let now = Utilities.getTime()
        let alertController = UIAlertController(title: "Save Documents", message: "Enter document name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            let name = alertController.textFields?[0].text
            if name != "" {
                if Utilities.checkSameName(fileName: name!, documents: self.documents) {
                    self.savePicture(picture: scannedImage, imageName: "\(name!) (1).jpg")
                } else {
                    self.savePicture(picture: scannedImage, imageName: "\(name!).jpg")
                }
            } else {
                self.savePicture(picture: scannedImage, imageName: "\(now).jpg")
            }
            self.documents = Utilities.getDocuments()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "\(now)"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        present(alertController, animated: true, completion: nil)
    }
    
}


extension ViewController: ImageScannerControllerDelegate {
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        if results.doesUserPreferEnhancedImage {
            scannedImage = results.enhancedImage
        } else {
            scannedImage = results.scannedImage
        }
        self.imgPlaceholder.image = scannedImage
        scanner.dismiss(animated: true, completion: nil)
        showSaveDialog(scannedImage: scannedImage)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
}

