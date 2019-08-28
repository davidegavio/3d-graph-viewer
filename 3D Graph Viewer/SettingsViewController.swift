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
    
    var unit: Float = 10
    var planes: Bool = true
    var axesLabels: Bool = true

    @IBOutlet weak var showAxesLabels: UISwitch!
    @IBOutlet weak var showPlanes: UISwitch!
    @IBOutlet weak var unitOfMeasure: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello I'm SettingsViewController")
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
        showAxesLabels.isOn = axesLabels
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
        //print(unit)
    }
    
    @IBAction func showPlanesSwitch(_ sender: Any) {
        planes = showPlanes.isOn
        //print(planes)
    }
    
    @IBAction func showAxesLabelsSwitch(_ sender: Any) {
        axesLabels = showAxesLabels.isOn
        //print(axesLabels)
    }
    
}
