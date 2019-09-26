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
    var unitMeasure: Double = 10
    var shouldPlanesBeShown = true
    var shouldAxesLabelsBeShown = true
    var opacity: Double = 0.5
    
    
    @IBOutlet weak var taskInAction: UIActivityIndicatorView! // The loading wheel
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var plotInOpenAirButton: UIButton!
    @IBOutlet weak var plotWithFiducialMarkerButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true // Option to prevent the screen to become dark
        plotInOpenAirButton.isEnabled = false // Plotting buttons are disabled until a file is chosen
        plotWithFiducialMarkerButton.isEnabled = false
        taskInAction.isHidden = true
        taskInAction.hidesWhenStopped = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case is AugmentedRealityCameraViewController:
                let vc = segue.destination as? AugmentedRealityCameraViewController
                vc?.pointsToPlot = pointsToPlot // Passing points and other variables to AugmentedRealityCameraViewController
                vc?.unitMeasure = unitMeasure
                vc?.shouldPlanesBeShown = shouldPlanesBeShown
                vc?.opacity = opacity
            case is AugmentedRealityFiducialMarkerViewController:
                let vc = segue.destination as? AugmentedRealityFiducialMarkerViewController
                vc?.pointsToPlot = pointsToPlot // Passing points and other variables to AugmentedRealityFiducialMarkerViewController
                vc?.pickedImage = tempImage
                vc?.scannedPicture = scannedPicture
                vc?.unitMeasure = unitMeasure
                vc?.shouldPlanesBeShown = shouldPlanesBeShown
                vc?.opacity = opacity
            case is SettingsViewController:
                let vc = segue.destination as? SettingsViewController
                vc?.unit = unitMeasure
                vc?.planes = shouldPlanesBeShown
                vc?.opacity = opacity
            default:
                print("This is not the ViewController you're looking for")
        }
    }
    
    @IBAction func plotButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toARCameraSegue", sender: self)
    }
    
    @IBAction func plotOnFiducialMarkerButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toARCameraFiducialMarkerSegue", sender: self)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSettingsViewControllerSegue", sender: self)
    }
    
    /**
     * Method that retrieves information from settings screen
     */
    @IBAction func unwindFromSettings(_ sender: UIStoryboardSegue){
        if sender.source is SettingsViewController{
            if let senderVC = sender.source as? SettingsViewController{
                unitMeasure = senderVC.unit
                shouldPlanesBeShown = senderVC.planes
                opacity = senderVC.opacity
            }
        }
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
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /**
     * Opens the camera in order to take a picture.
     * Reads the picture to retrieve information from the contained QR Code
     */
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
     */
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
                    if valuesArray.count > 6 {
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
        if pointsToPlot.count > 1500{
            let alertController = UIAlertController(title: "Warning!", message:
                "Current amount of points can cause crashes due to memory saturation.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}

