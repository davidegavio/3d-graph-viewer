//
//  ViewController.swift
//  3D Graph Viewer
//
//  Created by Davide Gavio on 10/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    var pointsToPlot: [Point] = [] // List of points contained in csv file
    let defaultRColour = "5"
    let defaultGColour = "52"
    let defaultBColour = "105"
    
    @IBOutlet weak var taskInAction: UIActivityIndicatorView! // The loading wheel
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var plotInOpenAirButton: UIButton!
    @IBOutlet weak var plotWithFiducialMarkerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotInOpenAirButton.isEnabled = false // Plotting buttons are disabled until a file is chosen
        plotWithFiducialMarkerButton.isEnabled = false
        taskInAction.isHidden = true
        taskInAction.hidesWhenStopped = true
        self.navigationItem.title = "3D Graph Viewer"
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AugmentedRealityCameraViewController:
            let vc = segue.destination as? AugmentedRealityCameraViewController
            vc?.pointsToPlot = pointsToPlot // Passing points to AugmentedRealityCameraViewController
        case is AugmentedRealityFiducialMarkerViewController:
            let vc = segue.destination as? AugmentedRealityFiducialMarkerViewController
            vc?.pointsToPlot = pointsToPlot // Passing points to AugmentedRealityFiducialMarkerViewController
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
    
    /**
    * The user chooses the file to import points information
    * The reading operation is performed in a separated thread in order to keep unlocked the main one
    */
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL){
        let fileUrl = url as URL
        print("Import result: \(fileUrl)")
        taskInAction.isHidden = false // Shows the loading wheel
        taskInAction.startAnimating() // Animates the loading wheel
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in // Reading operation in separate thread
            guard let self = self else {
                return
            }
            do{
                let wholeFile = try String(contentsOf: fileUrl)
                let rowsOfCsv = wholeFile.components(separatedBy: "\n") // Splits the file when a newline is found
                for singleRow in rowsOfCsv {
                    let valuesArray = singleRow.components(separatedBy: ",") // Isolates point attributes splitting with the comma
                    if valuesArray.count > 2 {
                        let point: Point = Point(valuesArray: valuesArray)
                        self.pointsToPlot.append(point)
                        point.printAllValues()
                    }
                }
            } catch _{ print("Error parsing csv file!") }
            
        }
        fileInfoLabel.text = fileUrl.lastPathComponent + " contains " + String(pointsToPlot.count) + " points to plot"
        //fileInfoLabel.lineBreakMode = .byWordWrapping
        fileInfoLabel.numberOfLines = 0
        taskInAction.stopAnimating() // Stops the loading wheel animation
        plotInOpenAirButton.isEnabled = true // File chosen, plot buttons get enabled
        plotWithFiducialMarkerButton.isEnabled = true
    }
    
    private func documentMenuWasCancelled(_ documentMenu: UIDocumentPickerViewController) {
        print("View was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseFileButton(_ sender: Any) {
        pointsToPlot.removeAll() // Choosing a new file cleans old points
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeRTF)], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
}

