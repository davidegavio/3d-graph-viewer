//
//  Point.swift
//  3D Graph Viewer
//
//  Created by Admin on 10/05/2019.
//  Copyright © 2019 Davide Gavio. All rights reserved.
//

import Foundation

struct Point {
    var xCoordinate = ""
    var yCoordinate = ""
    var zCoordinate = ""
    var rColour = ""
    var gColour = ""
    var bColour = ""
    
    init(xCoordinate: String, yCoordinate: String, zCoordinate: String, rColour: String, gColour: String, bColour: String) {
     self.xCoordinate = xCoordinate
     self.yCoordinate = yCoordinate
     self.zCoordinate = zCoordinate
     self.rColour = rColour
     self.gColour = gColour
     self.bColour = bColour
     }
    
    init(valuesArray: [String]){
        self.xCoordinate = valuesArray[0]
        self.yCoordinate = valuesArray[1]
        self.zCoordinate = valuesArray[2]
        self.rColour = valuesArray[3]
        self.gColour = valuesArray[4]
        self.bColour = valuesArray[5]
    }
    
    public func printAllValues(){
        print("Your point with xyz coordinates: (\(self.xCoordinate); \(self.yCoordinate); \(self.zCoordinate)) and rgb colour: (\(self.rColour)\(self.gColour)\(self.bColour)).")
    }
    
}
