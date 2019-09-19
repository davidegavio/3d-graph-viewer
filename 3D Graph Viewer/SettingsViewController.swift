//
//  SettingsViewController.swift
//  3D Graph Viewer
//
//  Created by Admin on 28/08/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    var unit: Double = 10
    var planes: Bool = true
    var axesLabels: Bool = true
    var opacity: Double = 0.3

    @IBOutlet weak var showAxesLabels: UISwitch!
    @IBOutlet weak var showPlanes: UISwitch!
    @IBOutlet weak var unitOfMeasure: UISegmentedControl!
    @IBOutlet weak var setOpacity: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Hello I'm SettingsViewController")
        switch unit{
        case 1000:
            unitOfMeasure.selectedSegmentIndex = 0
        case 100:
            unitOfMeasure.selectedSegmentIndex = 1
        case 10:
            unitOfMeasure.selectedSegmentIndex = 2
        case 1:
            unitOfMeasure.selectedSegmentIndex = 3
        default:
            unitOfMeasure.selectedSegmentIndex = 2
        }
        showPlanes.isOn = planes
        if(showPlanes.isOn){
            showAxesLabels.isEnabled = true
            showAxesLabels.isOn = axesLabels
        }else{
            showAxesLabels.isEnabled = false
            showAxesLabels.isOn = false
        }
        switch opacity{
        case 0.1:
            setOpacity.selectedSegmentIndex = 0
        case 0.5:
            setOpacity.selectedSegmentIndex = 1
        case 1:
            setOpacity.selectedSegmentIndex = 2
        default:
            setOpacity.selectedSegmentIndex = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveData(_ unwindSegue: UIStoryboardSegue){
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let unitSend = unit
        let axesSend = axesLabels
        let planesSend = planes
        let opacitySend = opacity
    }
    
    
    @IBAction func unitOfMeasureSelector(_ sender: Any) {
        switch unitOfMeasure.selectedSegmentIndex{
            case 0:
                unit = 1000
            case 1:
                unit = 100
            case 2:
                unit = 10
            case 3:
                unit = 1
            default:
                unit = 10
            }
    }
    
    @IBAction func showPlanesSwitch(_ sender: Any) {
        planes = showPlanes.isOn
        showAxesLabels.isEnabled = true
        if(!showPlanes.isOn){
            showAxesLabels.isEnabled = false
            showAxesLabels.isOn = false
        }
    }
    
    @IBAction func showAxesLabelsSwitch(_ sender: Any) {
        axesLabels = showAxesLabels.isOn
    }
    
    @IBAction func setOpacityValue(_ sender: Any) {
        switch setOpacity.selectedSegmentIndex{
        case 0:
            opacity = 0.1
        case 1:
            opacity = 0.5
        case 2:
            opacity = 1
        default:
            opacity = 0.1
        }
    }
    
    
}

