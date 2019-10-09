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
        taskInAction.isHidden = true
        augmentedRealityScatterplot.delegate = self
        //augmentedRealityScatterplot.showsStatistics = true
        //augmentedRealityScatterplot.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        let scene = SCNScene()
        augmentedRealityScatterplot.scene = scene
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:))) // Tap gesture recognizer
        augmentedRealityScatterplot.addGestureRecognizer(tapRec) // Adding gesture recognizer to sceneview
        originNode = SCNNode()
        originNode.position = SCNVector3(0, -0.2, -1)
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
     */
    private func plotPoints(){
        self.taskInAction.isHidden = false // Shows the loading wheel
        self.taskInAction.startAnimating() // Animates the loading wheel
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in // Adding points in separate thread
            guard let self = self else {
                return
            }
            do{
                var i = 0 // Variable used to identify sequentially a sphere inside the array
                for point in self.pointsToPlot{
                    let sphere = SCNSphere(radius: CGFloat(self.calculateDouble(decimal: point.sizeCoefficient)))
                    if(sphere.radius > self.maxPointRadius){
                        self.maxPointRadius = sphere.radius
                    }
                    let tempMax = max(max(Double(point.xCoordinate)!, Double(point.yCoordinate)!), Double(point.zCoordinate)!)
                    if tempMax > self.maxIndex{
                        self.maxIndex = tempMax
                    }
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.name = "Name: " + String(i) // Assigning a name to a single sphere node
                    i += 1
                    sphere.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(Double(point.rColour) ?? 5)/255, green: CGFloat(Double(point.gColour) ?? 52)/255, blue: CGFloat(Double(point.bColour) ?? 105)/255, alpha: 1)
                    sphereNode.position = SCNVector3(Double(point.xCoordinate)!/self.unitMeasure, Double(point.yCoordinate)!/self.unitMeasure, Double(point.zCoordinate)!/self.unitMeasure) // Setting the unit measure, eg. dividing by 10 sets the unit to dm
                    self.originNode.addChildNode(sphereNode)
                }
                if self.shouldPlanesBeShown{
                    self.addPlanes()
                }
                self.augmentedRealityScatterplot.scene.rootNode.addChildNode(self.originNode)
            }
            DispatchQueue.main.async {
                self.taskInAction.stopAnimating() // Stops the loading wheel animation
                self.taskInAction.isHidden = true
            }
        }
    }
    
    /**
     * Calculates the divider for the point size.
     * If the size is too big it gets divided in order to obtain a smaller one.
     */
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
    
    
    /**
     * Adds the planes to the view.
     */
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
    
    
    /**
     * Presents an info alert with graph information.
     */
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
