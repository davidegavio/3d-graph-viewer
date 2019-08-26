//
//  ViewController.swift
//  3D Graph Viewer
//
//  Created by Davide Gavio on 10/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation


class ViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pointsToPlot: [Point] = [] // List of points contained in csv file
    var tempImage: CIImage?
    let defaultRColour = "5"
    let defaultGColour = "52"
    let defaultBColour = "105"
    var scannedPicture = false
    var unitMeasure: Float = 10
    
    @IBOutlet weak var taskInAction: UIActivityIndicatorView! // The loading wheel
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var plotInOpenAirButton: UIButton!
    @IBOutlet weak var plotWithFiducialMarkerButton: UIButton!
    @IBOutlet weak var unitSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotInOpenAirButton.isEnabled = false // Plotting buttons are disabled until a file is chosen
        plotWithFiducialMarkerButton.isEnabled = false
        taskInAction.isHidden = true
        taskInAction.hidesWhenStopped = true
        self.navigationItem.title = "3D Graph Viewer"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is AugmentedRealityCameraViewController:
            let vc = segue.destination as? AugmentedRealityCameraViewController
            vc?.pointsToPlot = pointsToPlot // Passing points to AugmentedRealityCameraViewController
            vc?.unitMeasure = unitMeasure
        case is AugmentedRealityFiducialMarkerViewController:
            let vc = segue.destination as? AugmentedRealityFiducialMarkerViewController
            vc?.pointsToPlot = pointsToPlot // Passing points to AugmentedRealityFiducialMarkerViewController
            vc?.pickedImage = tempImage
            vc?.scannedPicture = scannedPicture
            vc?.unitMeasure = unitMeasure
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
        // In the following do/try/catch block the file is converted into a string
        var wholeFile = ""
        do{
            wholeFile = try String(contentsOf: fileUrl)
        }
        catch _{ print("Error parsing csv file!") }
        readFile(wholeFile: wholeFile)
        fileInfoLabel.text = fileUrl.lastPathComponent + " contains " + String(pointsToPlot.count) + " points to plot"
        fileInfoLabel.numberOfLines = 0
        
    }
    
    private func documentMenuWasCancelled(_ documentMenu: UIDocumentPickerViewController) {
        print("View was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseFileButton(_ sender: Any) {
        scannedPicture = false
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeRTF)], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func scanFromPictureButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])! // QRCode reader from CoreImage library
            var qrCodeData = ""
            let ciImage: CIImage = CIImage(image: pickedImage)! // Converting the picked photo in a Core Image compatible format
            tempImage = ciImage
            let features = detector.features(in: ciImage) // Searches for features in image
            for feature in features as! [CIQRCodeFeature] {
                qrCodeData += feature.messageString!
            }
            scannedPicture = true
            readFile(wholeFile: qrCodeData)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
    * Generalized method: now wheter data comes from a pictures or a document the behaviour is the same.
    * Reads the input string, creates for each row a Point and appends to the points to plot list.
    **/
    private func readFile(wholeFile: String){
        pointsToPlot.removeAll() // Reading a new file cleans the points list
        taskInAction.isHidden = false // Shows the loading wheel
        taskInAction.startAnimating() // Animates the loading wheel
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in // Reading operation in separate thread
            guard let self = self else {
                return
            }
            do{
                let rowsOfCsv = wholeFile.components(separatedBy: "\n") // Splits the file when a newline is found
                for singleRow in rowsOfCsv {
                    let valuesArray = singleRow.components(separatedBy: ",") // Isolates point attributes splitting with the comma
                    if valuesArray.count > 2 {
                        let point: Point = Point(valuesArray: valuesArray)
                        self.pointsToPlot.append(point)
                    }
                }
            }
            if(pointsToPlot.count > 0){
                plotInOpenAirButton.isEnabled = true // File chosen, plot buttons get enabled
                plotWithFiducialMarkerButton.isEnabled = true
                fileInfoLabel.text = "The picture contains " + String(pointsToPlot.count) + " points to plot"
            }
            else{
                fileInfoLabel.text = "The picture doesn't contain any data"
            }
            taskInAction.stopAnimating() // Stops the loading wheel animation
            
        }
    }
    
    @IBAction func unitChosen(_ sender: Any) {
        switch unitSelector.selectedSegmentIndex{
            case 0:
                unitMeasure = 1000
            case 1:
                unitMeasure = 100
            case 2:
                unitMeasure = 10
            case 3:
                unitMeasure = 1
            default:
                unitMeasure = 1
        }
    }
}

