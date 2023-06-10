//
//  GameViewController.swift
//  Jumpscare
//
//  Created by Jeremy Christopher on 29/05/23.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var sceneView:SCNView!
    var scene:SCNScene!
    
    var ghostNode: SCNNode!
    var spotLightNode: SCNNode!
    
    var ghostJumpScare: SCNNode!
    
    var isFirstContact = true
    
    var sounds:[String:SCNAudioSource] = [:]

    override func viewDidLoad()
    {
        setUpScene()
        setUpNodes()
        setupSounds()

    }
    
    func setUpScene(){
        sceneView = self.view as! SCNView
        sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        scene.lightingEnvironment.intensity = -1
        sceneView.scene = scene
        sceneView.delegate = self
        scene.physicsWorld.contactDelegate = self
        
//        to see physics shape
//        sceneView.debugOptions = [.showPhysicsShapes]
        
    }
    
    func setUpNodes(){
        ghostNode = scene.rootNode.childNode(withName: "ghost contact", recursively: true)
        spotLightNode = scene.rootNode.childNode(withName: "spotLight", recursively: true)
        ghostJumpScare = scene.rootNode.childNode(withName: "jumpscare", recursively: true)
        ghostJumpScare.isHidden = true
    }
        
    func setupSounds() {
        let screamSound = SCNAudioSource(fileNamed: "scream.mp3")!
        screamSound.volume = 10.5
        screamSound.load()
        sounds["scream"] = screamSound
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = sceneView.pointOfView else {
            return
        }
        spotLightNode.position = pov.position
        spotLightNode.orientation = pov.orientation
        spotLightNode.eulerAngles = pov.eulerAngles

    }
}

extension GameViewController: SCNPhysicsContactDelegate{
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if(isFirstContact){
            let moveAction = SCNAction.move(to: SCNVector3(x: ghostNode.position.x, y: ghostNode.position.y, z: -ghostNode.position.z), duration: 0)
            ghostNode.runAction(moveAction)

            let sawSound = sounds["scream"]!
            sceneView.scene?.rootNode.runAction(SCNAction.playAudio(sawSound, waitForCompletion: false))
            
            let unhideAction = SCNAction.run { (node) in
                node.isHidden = false
            }

            let waitAction = SCNAction.wait(duration: 5)

            let hideAction = SCNAction.run { (node) in
                node.isHidden = true
            }
            let jumpScare = SCNAction.sequence([unhideAction, waitAction, hideAction])
            ghostJumpScare.runAction(jumpScare)
        }
        isFirstContact = false
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        isFirstContact = true
    }
}


