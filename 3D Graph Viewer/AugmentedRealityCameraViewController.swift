//
//  AugmentedRealityCameraViewController.swift
//  3D Graph Viewer
//
//  Created by Admin on 15/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import ARKit

class AugmentedRealityCameraViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var augmentedRealityScatterplot: ARSCNView!
    let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    var pointsToPlot: [Point] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentedRealityScatterplot.delegate = self
        augmentedRealityScatterplot.showsStatistics = true
        augmentedRealityScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityScatterplot.scene = scene
        print("Hello I'm second viewcontroller")
        print(pointsToPlot)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arWorldTrackingConfiguration.planeDetection = .horizontal
        augmentedRealityScatterplot.session.run(arWorldTrackingConfiguration)
        plotPoints()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
        if anchor is ARPlaneAnchor{
            print("Horizontal plane detected!")
        }
    }
    
    private func plotPoints(){
        for point in pointsToPlot{
            let sphere = SCNSphere(radius: 0.1)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(Float(point.xCoordinate)!, Float(point.yCoordinate)!, Float(point.zCoordinate)!)
            augmentedRealityScatterplot.scene.rootNode.addChildNode(sphereNode)
        }
        print("Plotting points!")
    }
}
