# 3D Graph Viewer
iOS application that takes in input a CSV file that contains a set of points in 3D and then plots them as a 3D scatterplot in AR.
# Requirements
To run ARKit you need a device with at least [A9](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html) chip.
Compatible devices are:
* iPhone 6s and 6s Plus
* iPhone 7 and 7 Plus
* iPhone SE
* iPad Pro (9.7, 10.5 or 12.9) – both first-gen and 2nd-gen
* iPad (2017)
* iPhone 8 and 8 Plus
* iPhone X
* More recent devices

Development and testing device: iPhone 6s updated to iOS 12.1

Swift version: 4.2

Inside the repo are contained a couple of fiducial markers and some test csv files.

# Functions
The app functions are:
* Retrieving information from CSV file contained in the device memory or hosted on a cloud storage
* Retrieving information from a picture containing a QR Code
* Free graph plot
* Fiducial marker plot
# Limits
In order to use flawlessly the app it is advised to use files containing not more than 1500 point.
The app works even with more points, with poor performances in term of memory, battery and frame per second.
# Screenshots
<img src="https://user-images.githubusercontent.com/19225432/65675675-e1b02880-e04e-11e9-9e38-6a34e3a50b97.PNG" width=150 align=left>
<img src="https://user-images.githubusercontent.com/19225432/65675671-e1179200-e04e-11e9-8631-11cd43b36c25.PNG" width=150 align=left>
<img src="https://user-images.githubusercontent.com/19225432/65675674-e1179200-e04e-11e9-8c57-192118cb250d.PNG" width=150 align=left>
<img src="https://user-images.githubusercontent.com/19225432/65675679-e1b02880-e04e-11e9-89c3-3cdf1f1ef6ed.PNG" width=150 align=left>
<img src="https://user-images.githubusercontent.com/19225432/65675678-e1b02880-e04e-11e9-81e0-0130d860a5cc.PNG" width=150 align=left>
