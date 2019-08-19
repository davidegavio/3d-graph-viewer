//
//  AugmentedRealityCameraViewController.swift
//  3D Graph Viewer
//
//  Created by Davide Gavio on 15/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import ARKit

class AugmentedRealityCameraViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var augmentedRealityScatterplot: ARSCNView!
    let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    var pointsToPlot: [Point] = []
    var sphereNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentedRealityScatterplot.delegate = self
        augmentedRealityScatterplot.showsStatistics = true
        augmentedRealityScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityScatterplot.scene = scene
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:))) // Tap gesture recognizer
        augmentedRealityScatterplot.addGestureRecognizer(tapRec) // Adding gesture recognizer to sceneview
        print("Hello I'm AugmentedRealityCameraViewController")
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
    
    /**
    * This method plots the points inherited from ViewController.
    * It also creates the pysical points and sets their attributes.
    **/
    private func plotPoints(){
        addPlanes()
        var i = 0 // Variable used to identify sequentially a sphere inside the array
        for point in pointsToPlot{
            let sphere = SCNSphere(radius: CGFloat(Float(point.sizeCoefficient) ?? 0.03))
            //let sphere = SCNSphere(radius: 1)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.name = "Name: " + String(i) // Assigning a name to a single sphere node
            i += 1
            sphere.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(Float(point.rColour) ?? 5), green: CGFloat(Float(point.gColour) ?? 52), blue: CGFloat(Float(point.bColour) ?? 105), alpha: 1)
            sphereNode.position = SCNVector3(Float(point.xCoordinate)!/10, Float(point.yCoordinate)!/10, Float(point.zCoordinate)!/10)
            print(sphereNode.position)
            augmentedRealityScatterplot.scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    private func addPlanes(){
        let verticalNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        let horizontalNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        let sideNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        verticalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        verticalNode.opacity = 0.5
        horizontalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        horizontalNode.geometry?.firstMaterial?.isDoubleSided = true
        horizontalNode.eulerAngles = SCNVector3(90.toRadians, 0, 0)
        horizontalNode.opacity = 0.5
        sideNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        sideNode.eulerAngles = SCNVector3(0, 90.toRadians, 0)
        sideNode.geometry?.firstMaterial?.isDoubleSided = true
        sideNode.opacity = 0.5
        augmentedRealityScatterplot.scene.rootNode.addChildNode(verticalNode)
        augmentedRealityScatterplot.scene.rootNode.addChildNode(horizontalNode)
        augmentedRealityScatterplot.scene.rootNode.addChildNode(sideNode)
    }
    
    /**
    * @objc annotation used to make available to Objective-C.
    * Some parts of iOS workflow is handled by Objective-C code.
    **/
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended { // When the tap event ends
            let location: CGPoint = rec.location(in: augmentedRealityScatterplot) // Gets the location of the tap
            let hits = self.augmentedRealityScatterplot.hitTest(location, options: nil)
            if !hits.isEmpty{ // A list of hit events
                let tappedNode = hits.first?.node
                print(tappedNode ?? "Nothing tapped")
            }
        }
    }
    
}

/**
* Extending the Int type in order to convert to radians.
**/
extension Int{ var toRadians: Double{ return Double(self) * .pi / 180} }
