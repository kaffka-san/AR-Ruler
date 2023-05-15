//
//  ViewController.swift
//  AR Ruler
//
//  Created by Anastasia Lenina on 15.05.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
       // sceneView.showsStatistics = true
        
        
        // Set the scene to the view
       
      //  sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            textNode.removeFromParentNode()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any) else {return}
            let results = sceneView.session.raycast(query)
            guard let hitTestResult = results.first
            else {
                print("No surface found")
                return
            }
            sceneView.scene.rootNode.addChildNode(addDot(at: hitTestResult))
            
          
        }
    }
    func addDot(at location: ARRaycastResult ) -> SCNNode {
        let sphere = SCNSphere(radius: 0.002)
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = SCNVector3(x: Float(location.worldTransform.columns.3.x),
                                         y: Float(location.worldTransform.columns.3.y + sphereNode.boundingSphere.radius),
                                         z: Float(location.worldTransform.columns.3.z))
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.magenta
        sphereNode.geometry?.materials = [material]
        dotNodes.append(sphereNode)
        if dotNodes.count >= 2 {
            calculate()
        }
        
        return sphereNode
    }
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        print(abs(distance))
       
updateText(text: "\(String(format: "%.1f", distance * 100)) cm", atPosition: start.position)
    }
   
    func updateText(text: String, atPosition position : SCNVector3){
       
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.magenta

        textGeometry.font =   UIFont(name: "Helvetica", size: 80)
        textNode.geometry = textGeometry
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.03 , z: position.z)
        textNode.scale = SCNVector3(0.0004, 0.0004, 0.0004)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

   
}
