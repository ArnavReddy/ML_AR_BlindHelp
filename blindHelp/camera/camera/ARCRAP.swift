//
//  ViewController.swift
//  AR Ruler
//
//  Created by Angela Yu on 31/07/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARCRAP: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var SpeakButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var textVar = ""
    var saveX = 0.0
    var saveY = 0.0
    var saveZ = 0.0
    
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configurationImage = ARImageTrackingConfiguration()
        let configuration = ARWorldTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: Bundle.main) {
                   
            configuration.detectionImages = trackedImages
                   
                   configuration.maximumNumberOfTrackedImages = 1
                   
               }
        // Run the view's session
        //sceneView.session.run(configurationImage)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
           
        print("len", dotNodes.count)
           let node = SCNNode()
           
           if let imageAnchor = anchor as? ARImageAnchor {
               
               let x = imageAnchor.transform
                  print(x.columns.3.x, x.columns.3.y , x.columns.3.z)
            
            print("HELLLOOOOO")
            
            saveX = Double(x.columns.3.x)
            saveY = Double(x.columns.3.y)
            saveZ = Double(x.columns.3.z)
            
            let dotGeometry = SCNSphere(radius: 0.005)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            dotGeometry.materials = [material]
            
            if(saveX > 0.0001){
               let dotNode = SCNNode(geometry: dotGeometry)
                      let dotNodetemp = SCNNode(geometry: dotGeometry)

                      dotNodetemp.position = SCNVector3(saveX, saveY, saveZ)
                      print("postion PIC= ",saveX)
                      //print("node = ",dotNode)
                      
                      
                      sceneView.scene.rootNode.addChildNode(dotNode)
                      
                      
                      
                if(dotNodes.count == 1)
                { dotNodes.append(dotNodetemp) }
                
                if dotNodes.count >= 2 {
                    calculate()
                }
            }
            
               
               let videoNode = SKVideoNode(fileNamed: "harrypotter.mp4")
               
               videoNode.play()
               
               let videoScene = SKScene(size: CGSize(width: 480, height: 360))
               
               
               videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
               
               videoNode.yScale = -1.0
               
               videoScene.addChild(videoNode)
               
               
               let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
               
               plane.firstMaterial?.diffuse.contents = videoScene
               
               let planeNode = SCNNode(geometry: plane)
               
               planeNode.eulerAngles.x = -.pi / 2
               
               node.addChildNode(planeNode)
               
           }
           
           return node
           
       }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    func addDot(at hitResult : ARHitTestResult) {
        
        if(dotNodes.count==0)
        {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        
           let dotNode = SCNNode(geometry: dotGeometry)
                  //let dotNodetemp = SCNNode(geometry: dotGeometry)
                  
                  print(saveX, saveY, saveZ)
                  print("count", dotNodes.count)
                   dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                  print("postion = ",dotNode.position)
                  print("node = ",dotNode)
                  
                  
                  sceneView.scene.rootNode.addChildNode(dotNode)
                  
                  
                  
                  dotNodes.append(dotNode)
            if dotNodes.count >= 2 {
                calculate()
            }
        
        }
    }
    
    func calculate (){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(abs(distance*100/2.54)) inches", atPosition: end.position)
        
//        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textVar = text
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    @IBAction func speakButtonPressed(_ sender: UIButton) {
        let utterance = AVSpeechUtterance(string: textVar)
                      utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                      utterance.rate = 0.3

                      let synthesizer = AVSpeechSynthesizer()
                      synthesizer.speak(utterance)
                      
                      self.textView.text = textVar
    }
    
}












