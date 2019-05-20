//
//  AugmentedRealityCameraViewController.swift
//  3D Graph Viewer
//
//  Created by Admin on 15/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import ARKit

class AugmentedRealityCameraViewController: UIViewController {
    
    @IBOutlet weak var augmentedRealityScatterplot: ARSCNView!
    let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello I'm second viewcontroller")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        augmentedRealityScatterplot.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        augmentedRealityScatterplot.session.run(arWorldTrackingConfiguration)
    }
    
    
    
    
}
