//
//  ViewController.swift
//  3D Graph Viewer
//
//  Created by Admin on 10/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    var pointsToPlot: [Point] = []
    
    @IBOutlet weak var taskInAction: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskInAction.isHidden = true
        taskInAction.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func plotButton(_ sender: Any) {
        print("Plot button pressed!")
        performSegue(withIdentifier: "toARCameraSegue", sender: self)
    }
    
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL){
        let fileUrl = url as URL
        print("Import result: \(fileUrl)")
        taskInAction.isHidden = false
        taskInAction.startAnimating()
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
            guard let self = self else {
                return
            }
            do{
                let wholeFile = try String(contentsOf: fileUrl)
                let rowsOfCsv = wholeFile.components(separatedBy: "\n")
                for singleRow in rowsOfCsv {
                    let valuesArray = singleRow.components(separatedBy: ",")
                    if valuesArray.count > 2 {
                        let point: Point = Point(valuesArray: valuesArray)
                        self.pointsToPlot.append(point)
                        point.printAllValues()
                    }
                }
            } catch _{ print("Error parsing csv file!") }
            
        }
        taskInAction.stopAnimating()
        
    }
    
    private func documentMenuWasCancelled(_ documentMenu: UIDocumentPickerViewController) {
        print("View was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func chooseFileButton(_ sender: Any) {
        pointsToPlot.removeAll()
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeRTF)    ], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
 
}

