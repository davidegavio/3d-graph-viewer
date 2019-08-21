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
    var customReferenceSet = Set<ARReferenceImage>()
    var pointsToPlot: [Point] = []
    var sphereNodes: [SCNNode] = []
    var scannedPicture = false
    var isImageDetected = false
    var isPlaneDetected = false
    var lastImagePosition: simd_float4x4?
    var lastReferenceImageDetected: ARReferenceImage?
    var isHorizontalPlaneDetected = false
    var shouldScatterplotBePlacedUponImage = true
    var originNode: SCNNode!
    var pickedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(scannedPicture == true){
            addReference()
        }
        augmentedRealityFiducialMarkerScatterplot.delegate = self
        augmentedRealityFiducialMarkerScatterplot.showsStatistics = true
        augmentedRealityFiducialMarkerScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityFiducialMarkerScatterplot.scene = scene
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:))) // Tap gesture recognizer
        augmentedRealityFiducialMarkerScatterplot.addGestureRecognizer(tapRec) // Adding gesture recognizer to sceneview
        originNode = SCNNode()
        print("Hello I'm AugmentedRealityFiducialMarkerViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Something went wrong importing resources.")
        }
        arWorldTrackingConfiguration.planeDetection = .horizontal
        arWorldTrackingConfiguration.detectionImages = customReferenceSet
        augmentedRealityFiducialMarkerScatterplot.session.run(arWorldTrackingConfiguration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        manageSceneStateChanges(withAnchor: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        manageSceneStateChanges(withAnchor: anchor)
    }
    
    private func manageSceneStateChanges(withAnchor anchor: ARAnchor){
        if let imageAnchor = anchor as? ARImageAnchor{
            if shouldScatterplotBePlacedUponImage{
                lastImagePosition = imageAnchor.transform
                let referenceImage = imageAnchor.referenceImage
                referenceImage.name = "Reference QR Code image"
                lastReferenceImageDetected = referenceImage
                addPlanes()
                placeScatterplotAt(position: lastImagePosition!)
                augmentedRealityFiducialMarkerScatterplot.scene.rootNode.addChildNode(originNode)
                originNode.transform = SCNMatrix4(lastImagePosition!)
                shouldScatterplotBePlacedUponImage = false
            }
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
        var i = 0 // Variable used to identify sequentially a sphere inside the array
        for point in pointsToPlot{
            let sphere = SCNSphere(radius: CGFloat(Float(point.sizeCoefficient) ?? 0.03))
            let sphereNode = SCNNode(geometry: sphere)
            sphere.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(Float(point.rColour) ?? 5)/255, green: CGFloat(Float(point.gColour) ?? 52)/255, blue: CGFloat(Float(point.bColour) ?? 105)/255, alpha: 1)
            sphereNode.position = SCNVector3(Float(point.xCoordinate)!/10, Float(point.yCoordinate)!/10, Float(point.zCoordinate)!/10)
            sphereNode.name = "Name: " + String(i) // Assigning a name to a single sphere node
            i += 1
            originNode.addChildNode(sphereNode)
            print(sphereNode.position)
            }
    }
    
    private func addPlanes(){
        print("Adding planes")
        let verticalNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        let horizontalNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        let sideNode = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        verticalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        verticalNode.opacity = 0.5
        verticalNode.transform = SCNMatrix4(lastImagePosition!)
        verticalNode.eulerAngles = SCNVector3(90.toRadians, 0, 0)
        verticalNode.geometry?.firstMaterial?.isDoubleSided = true
        verticalNode.eulerAngles = SCNVector3(0, 0, 0)
        horizontalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        horizontalNode.transform = SCNMatrix4(lastImagePosition!)
        horizontalNode.eulerAngles = SCNVector3(90.toRadians, 0, 0)
        horizontalNode.geometry?.firstMaterial?.isDoubleSided = true
        horizontalNode.opacity = 0.5
        sideNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        sideNode.transform = SCNMatrix4(lastImagePosition!)
        sideNode.eulerAngles = SCNVector3(0, 90.toRadians, 0)
        sideNode.geometry?.firstMaterial?.isDoubleSided = true
        sideNode.opacity = 0.5
        originNode.addChildNode(verticalNode)
        originNode.addChildNode(horizontalNode)
        originNode.addChildNode(sideNode)
    }
    
    /**
     * @objc annotation because the method is made available to Objective-C.
     * Some parts of iOS workflow is handled by Objective-C code.
     **/
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended { // When the tap event ends
            let location: CGPoint = rec.location(in: augmentedRealityFiducialMarkerScatterplot) // Gets the location of the tap
            let hits = self.augmentedRealityFiducialMarkerScatterplot.hitTest(location, options: nil)
            if !hits.isEmpty{ // A list of hit events
                let tappedNode = hits.first?.node
                print(tappedNode ?? "Nothing tapped")
            }
        }
    }
    
    func addReference(){
        guard let cgImage = pickedImage.cgImage else {return}
        let arImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(cgImage.width))
        print(cgImage.width)
        customReferenceSet.insert(arImage)
    }
    
}
