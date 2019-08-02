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
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileEntryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskInAction.isHidden = true
        taskInAction.hidesWhenStopped = true
        self.navigationItem.title = "3D Graph Viewer"
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AugmentedRealityCameraViewController:
            let vc = segue.destination as? AugmentedRealityCameraViewController
            vc?.pointsToPlot = pointsToPlot
        case is AugmentedRealityFiducialMarkerViewController:
            let vc = segue.destination as? AugmentedRealityFiducialMarkerViewController
            vc?.pointsToPlot = pointsToPlot
        default:
            print("This is not the ViewController you're looking for")
        }
    }
    
    @IBAction func plotButton(_ sender: Any) {
        print("Plot button pressed!")
        self.performSegue(withIdentifier: "toARCameraSegue", sender: self)
    }
    
    
    @IBAction func plotOnFiducialMarkerButton(_ sender: Any) {
        print("Plotting on fiducial marker!")
        self.performSegue(withIdentifier: "toARCameraFiducialMarkerSegue", sender: self)
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
        fileInfoLabel.text = fileUrl.lastPathComponent
        fileEntryLabel.text = String(pointsToPlot.count) + " points to plot"
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

