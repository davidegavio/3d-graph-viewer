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

    @IBOutlet weak var taskInAction: UIActivityIndicatorView!
    let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    var pointsToPlot: [Point] = []
    var sphereNodes: [SCNNode] = []
    var maxPointRadius: CGFloat = 0
    var maxIndex: Double = 0
    var unitMeasure: Double = 10
    var shouldPlanesBeShown = true
    var opacity: Double = 0.5
    var originNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentedRealityScatterplot.delegate = self
        augmentedRealityScatterplot.showsStatistics = true
        //augmentedRealityScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityScatterplot.scene = scene
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:))) // Tap gesture recognizer
        augmentedRealityScatterplot.addGestureRecognizer(tapRec) // Adding gesture recognizer to sceneview
        originNode = SCNNode()
        originNode.position = SCNVector3(0, -0.2, -1)
        // print("Hello I'm AugmentedRealityCameraViewController")
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
        self.taskInAction.isHidden = false // Shows the loading wheel
        self.taskInAction.startAnimating() // Animates the loading wheel
        DispatchQueue.global(qos: .userInitiated).sync { [weak self] in // Adding points in separate thread
            guard let self = self else {
                return
            }
            do{
                var i = 0 // Variable used to identify sequentially a sphere inside the array
                for point in pointsToPlot{
                    //let sphere = SCNSphere(radius: CGFloat(Double(point.sizeCoefficient)!/unitMeasure ))
                    let sphere = SCNSphere(radius: CGFloat(calculateDouble(decimal: point.sizeCoefficient)))
                    if(sphere.radius > maxPointRadius){
                        maxPointRadius = sphere.radius
                    }
                    let tempMax = max(max(Double(point.xCoordinate)!, Double(point.yCoordinate)!), Double(point.zCoordinate)!)
                    if tempMax > maxIndex{
                        maxIndex = tempMax
                    }
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.name = "Name: " + String(i) // Assigning a name to a single sphere node
                    i += 1
                    sphere.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(Double(point.rColour) ?? 5)/255, green: CGFloat(Double(point.gColour) ?? 52)/255, blue: CGFloat(Double(point.bColour) ?? 105)/255, alpha: 1)
                    sphereNode.position = SCNVector3(Double(point.xCoordinate)!/unitMeasure, Double(point.yCoordinate)!/unitMeasure, Double(point.zCoordinate)!/unitMeasure) // Setting the unit measure, eg. dividing by 10 sets the unit to dm
                    let coordX = "\(sphereNode.position.x)"
                    let coordY = "\(sphereNode.position.y)"
                    let coordZ = "\(sphereNode.position.z)"
                    let textX = SCNText(string: coordX, extrusionDepth: CGFloat(1))
                    let textY = SCNText(string: coordY, extrusionDepth: CGFloat(1))
                    let textZ = SCNText(string: coordZ, extrusionDepth: CGFloat(1))
                    let textNodeX = SCNNode(geometry: textX)
                    let textNodeY = SCNNode(geometry: textY)
                    let textNodeZ = SCNNode(geometry: textZ)
                    textNodeX.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1) // UIColor needs values between 0 and 1 so the value is divided by 255
                    textNodeY.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1) // UIColor needs values between 0 and 1 so the value is divided by 255
                    textNodeZ.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1) // UIColor needs values between 0 and 1 so the value is divided by 255
                    textNodeX.position = SCNVector3(x: sphereNode.position.x, y: 0, z: 0)
                    textNodeY.position = SCNVector3(x: 0, y: sphereNode.position.y, z: 0)
                    textNodeZ.position = SCNVector3(x: 0, y: 0, z: sphereNode.position.z)
                    textNodeX.scale = SCNVector3(0.002,0.002,0.002)
                    textNodeY.scale = SCNVector3(0.002,0.002,0.002)
                    textNodeZ.scale = SCNVector3(0.002,0.002,0.002)
                    originNode.addChildNode(sphereNode)
                }
                if shouldPlanesBeShown{
                    addPlanes()
                }
                augmentedRealityScatterplot.scene.rootNode.addChildNode(originNode)
                self.taskInAction.stopAnimating() // Stops the loading wheel animation
                self.taskInAction.isHidden = true
            }
            
            
        }
        
    }
    
    private func calculateDouble(decimal: String) -> Double{
        let number = Double(decimal)!
        let zeros: Int = (decimal.split(separator: ".")[0]).count
        var divider: String = "1"
        if !decimal.starts(with: "0"){
            for _ in 0...zeros{
                divider = divider + "0"
            }
        }
        let doubleD = Double(divider)!
        return Double(number/doubleD)
    }
    
    private func addPlanes(){
        let verticalNode = SCNNode(geometry: SCNPlane(width: CGFloat((maxIndex+1)/5), height: CGFloat((maxIndex+1)/5)))
        let horizontalNode = SCNNode(geometry: SCNPlane(width: CGFloat((maxIndex+1)/5), height: CGFloat((maxIndex+1)/5)))
        let sideNode = SCNNode(geometry: SCNPlane(width: CGFloat((maxIndex+1)/5), height: CGFloat((maxIndex+1)/5)))
        verticalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        verticalNode.opacity = CGFloat(opacity)
        verticalNode.geometry?.firstMaterial?.isDoubleSided = true
        horizontalNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        horizontalNode.geometry?.firstMaterial?.isDoubleSided = true
        horizontalNode.eulerAngles = SCNVector3(90.toRadians, 0, 0)
        horizontalNode.opacity = CGFloat(opacity)
        sideNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
        sideNode.eulerAngles = SCNVector3(0, 90.toRadians, 0)
        sideNode.geometry?.firstMaterial?.isDoubleSided = true
        sideNode.opacity = CGFloat(opacity)
        originNode.addChildNode(verticalNode)
        originNode.addChildNode(horizontalNode)
        originNode.addChildNode(sideNode)
        
    }
    
    /**
    * @objc annotation used to make available to Objective-C.
    * Some parts of iOS workflow is handled by Objective-C code.
    **/
    @objc func handleTap(rec: UITapGestureRecognizer){
        originNode.childNodes.filter({$0.name == "Info"}).forEach({$0.removeFromParentNode()}) // Removing previous information text in order to have just one visible
        if rec.state == .ended { // When the tap event ends
            let location: CGPoint = rec.location(in: augmentedRealityScatterplot) // Gets the location of the tap
            let hits = self.augmentedRealityScatterplot.hitTest(location, options: nil)
            if !hits.isEmpty { // A list of hit events
                let tappedNode = hits.first?.node // The tapped node
                if tappedNode?.geometry is SCNSphere{ // Checking if the tapped node is actually the point, in order to not print useless information like planes infos
                    let text = "x: \(String(format: "%.2f", Double((tappedNode?.position.x)!) * unitMeasure)); \ny: \(String(format: "%.2f", Double((tappedNode?.position.y)!) * unitMeasure)); \nz: \(String(format: "%.2f", Double((tappedNode?.position.z)!) * unitMeasure));"
                    let textToShow = SCNText(string: text, extrusionDepth: CGFloat(1))
                    let textNode = SCNNode(geometry: textToShow)
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = [.X, .Y, .Z]
                    textNode.constraints = [billboardConstraint] // Keeps info label facing the camera
                    textNode.name = "Info"
                    textNode.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1) // UIColor needs values between 0 and 1 so the value is divided by 255
                    textNode.position = SCNVector3(Float((Double((tappedNode?.position.x)!)) + Double(maxPointRadius)), (tappedNode?.position.y)!, (tappedNode?.position.z)!)
                    textNode.scale = SCNVector3(0.002,0.002,0.002)
                    originNode.addChildNode(textNode)
                }
            }
        }
    }
    
    /*
    func showLabels(){
        for label in 0...(Int(maxIndex) + 1) {
            let labelToShow = SCNText(string: String(label), extrusionDepth: CGFloat(1))
            let labelNodeX = SCNNode(geometry: labelToShow)
            labelNodeX.position = SCNVector3(Double(label)/unitMeasure, 0, 0)
            labelNodeX.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeX.scale = SCNVector3(0.002,0.002,0.002)
            let labelNodeY = SCNNode(geometry: labelToShow)
            labelNodeY.position = SCNVector3(0, Double(label)/unitMeasure, 0)
            labelNodeY.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeY.scale = SCNVector3(0.002,0.002,0.002)
            let labelNodeZ = SCNNode(geometry: labelToShow)
            labelNodeZ.position = SCNVector3(0, 0, Double(label)/unitMeasure)
            labelNodeZ.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeZ.scale = SCNVector3(0.002,0.002,0.002)
            originNode.addChildNode(labelNodeX)
            originNode.addChildNode(labelNodeY)
            originNode.addChildNode(labelNodeZ)
        }
    }
    
    
    func showNegativeLabels(){
        for label in 0...(Int(maxIndex) + 1) {
            let labelToShow = SCNText(string: String(-label), extrusionDepth: CGFloat(1))
            let labelNodeX = SCNNode(geometry: labelToShow)
            labelNodeX.position = SCNVector3(-Double(label)/unitMeasure, 0, 0)
            labelNodeX.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeX.scale = SCNVector3(0.002,0.002,0.002)
            let labelNodeY = SCNNode(geometry: labelToShow)
            labelNodeY.position = SCNVector3(0, -Double(label)/unitMeasure, 0)
            labelNodeY.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeY.scale = SCNVector3(0.002,0.002,0.002)
            let labelNodeZ = SCNNode(geometry: labelToShow)
            labelNodeZ.position = SCNVector3(0, 0, -Double(label)/unitMeasure)
            labelNodeZ.geometry?.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            labelNodeZ.scale = SCNVector3(0.002,0.002,0.002)
            originNode.addChildNode(labelNodeX)
            originNode.addChildNode(labelNodeY)
            originNode.addChildNode(labelNodeZ)
        }
    }*/
    
    @IBAction func showGraphInfo(_ sender: Any) {
        var scale = ""
        switch unitMeasure {
        case 1:
            scale = "meters"
        case 10:
            scale = "decimeters"
        case 100:
            scale = "centimeters"
        case 1000:
            scale = "millimeters"
        default:
            scale = "decimeters"
        }
        let info = "Scale: \(scale) \nPlanes: \(shouldPlanesBeShown) \nOpacity: \(opacity)"
        let alertController = UIAlertController(title: "Graph information", message:
            info, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

/**
* Extending the Int type in order to convert to radians.
**/
extension Int{ var toRadians: Double{ return Double(self) * .pi / 180} }
