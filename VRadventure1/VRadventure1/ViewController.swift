//
//  ViewController.swift
//  VRadventure1
//
//  Created by Ted Goddard on 2016-08-18.
//  Copyright © 2016 Robots & Pencils. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var leftView: SCNView!
    @IBOutlet weak var rightView: SCNView!

    var cameraView: UIView?
    var motionManager: CMMotionManager?
    var environmentScene: SCNScene?
    var head: SCNNode?
    
    struct Constants {
        static let FarClip = 100.0
        static let NearClip = 0.01
        static let EyeSeparation = Float(0.02)
        static let FramesPerSecond = 1.0 / 60.0
    }
    
    enum EyePosition {
        case Left
        case Right
        
        var xPos: Float {
            switch self {
            case .Left:
                return -Constants.EyeSeparation
            case .Right:
                return Constants.EyeSeparation
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMotionManager()
        setupScenes()
    }

    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = Constants.FramesPerSecond
        motionManager?.startDeviceMotionUpdates(using: .xArbitraryZVertical)
    }

    private func setupScenes() {
        environmentScene = SCNScene(named: "Environment.scn")

        leftView.scene = environmentScene
        rightView.scene = environmentScene
        leftView.backgroundColor = .clear
        rightView.backgroundColor = .clear

        mountCamerasOnHead()

        leftView.delegate = self
        rightView.delegate = self

        leftView.isPlaying = true
        rightView.isPlaying = true

        addModels()
    }

    private func mountCamerasOnHead() {
        let leftCameraNode = cameraNode(forView: leftView, position: .Left)
        let rightCameraNode = cameraNode(forView: rightView, position: .Right)

        let head = SCNNode()
        head.name = "head"
        head.addChildNode(leftCameraNode)
        head.addChildNode(rightCameraNode)
        head.position = SCNVector3(x: 0.0, y: 1.5, z: 0.0)
        environmentScene?.rootNode.addChildNode(head)
        self.head = head

        leftView?.pointOfView = leftCameraNode
        rightView?.pointOfView = rightCameraNode
    }
    
    private func cameraNode(forView view: SCNView, position: EyePosition) -> SCNNode {
        let camera = SCNCamera()
        
        camera.zFar = Constants.FarClip
        camera.zNear = Constants.NearClip
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: position.xPos, y: 0.0, z: 0.0)
        
        view.pointOfView = cameraNode
        
        return cameraNode
    }

    private func addModels() {
        let modelLoader = ModelLoader(environmentScene: environmentScene)
        modelLoader.addAssortedMesh()
    }

    //MARK: SCNSceneRendererDelegate
    
    func renderer(_ aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        orientHead()
    }

    private func orientHead() {
        guard let mm = motionManager, let motion = mm.deviceMotion, let head = head else { return }

        let currentAttitude = motion.attitude
        let upsideDown = (UIApplication.shared.statusBarOrientation == .landscapeRight)
        let flipFactor = upsideDown ? -1.0 : 1.0
        let roll = flipFactor * currentAttitude.roll - M_PI_2
        let pitch = flipFactor * currentAttitude.pitch

        head.eulerAngles.x = Float(roll)
        head.eulerAngles.z = Float(pitch)
        head.eulerAngles.y = Float(currentAttitude.yaw)
    }

}
