//
//  AugmentedRealityFiducialMarkerViewController.swift
//  3D Graph Viewer
//
//  Created by Davide Gavio on 31/07/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import UIKit
import ARKit

class AugmentedRealityFiducialMarkerViewController: UIViewController, ARSCNViewDelegate{
    
    
    @IBOutlet weak var augmentedRealityFiducialMarkerScatterplot: ARSCNView!
    let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    var pointsToPlot: [Point] = []
    var sphereNodes: [SCNNode] = []
    var isImageDetected = false
    var isPlaneDetected = false
    var lastImagePosition:simd_float4x4?
    var lastReferenceImageDetected:ARReferenceImage?
    var isHorizontalPlaneDetected = false
    var shouldScatterplotBePlacedUponImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentedRealityFiducialMarkerScatterplot.delegate = self
        augmentedRealityFiducialMarkerScatterplot.showsStatistics = true
        augmentedRealityFiducialMarkerScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityFiducialMarkerScatterplot.scene = scene
        print("Hello I'm AugmentedRealityFiducialMarkerViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Something went wrong importing resources.")
        }
        arWorldTrackingConfiguration.planeDetection = .horizontal
        arWorldTrackingConfiguration.detectionImages = referenceImages
        augmentedRealityFiducialMarkerScatterplot.session.run(arWorldTrackingConfiguration)
        //augmentedRealityFiducialMarkerScatterplot.delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        manageSceneStateChanges(withAnchor: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        manageSceneStateChanges(withAnchor: anchor)
    }
    
    private func manageSceneStateChanges(withAnchor anchor: ARAnchor){
        if let imageAnchor = anchor as? ARImageAnchor{
            lastImagePosition = imageAnchor.transform
            let referenceImage = imageAnchor.referenceImage
            lastReferenceImageDetected = referenceImage
            print("Detected \(referenceImage.name!)")
            placeScatterplotAt(position: lastImagePosition!)
            shouldScatterplotBePlacedUponImage = false
        }
        isImageDetected = true
        if let planeAnchor = anchor as? ARPlaneAnchor{
            if planeAnchor.alignment == .horizontal{
                print("Horizontal plane detected!")
            }
        }
        isPlaneDetected = true
    }
    
    private func placeScatterplotAt(position: simd_float4x4){
        for point in pointsToPlot{
            let sphere = SCNSphere(radius: 0.03)
            //let sphere = SCNSphere(radius: 1)
            let sphereNode = SCNNode(geometry: sphere)
            sphere.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(Float(point.rColour) ?? 0), green: CGFloat(Float(point.gColour) ?? 255), blue: CGFloat(Float(point.bColour) ?? 255), alpha: 1)
            sphereNode.transform = SCNMatrix4(lastImagePosition!)
            sphereNode.position = SCNVector3((Float(point.xCoordinate)!+(lastImagePosition?.columns.3.x)!)/10, (Float(point.yCoordinate)!+(lastImagePosition?.columns.3.y)!)/10, (Float(point.zCoordinate)!+(lastImagePosition?.columns.3.z)!)/10)
            //sphereNode.position = SCNVector3(Float(point.xCoordinate)!/10, Float(point.yCoordinate)!/10, Float(point.zCoordinate)!/10)
            //let scaleAction = SCNAction.scale(by: 0.05, duration: 0)
            //jellyfishNode.runAction(scaleAction)
            augmentedRealityFiducialMarkerScatterplot.scene.rootNode.addChildNode(sphereNode)
            print(sphereNode.position)
            }
    }
    
}
