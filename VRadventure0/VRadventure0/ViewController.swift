//
//  ViewController.swift
//  VRadventure0
//
//  Created by Ted Goddard on 2016-08-04.
//  Copyright © 2016 Robots & Pencils. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var leftView: SCNView!
    @IBOutlet weak var rightView: SCNView!

    let farClip = 100.0
    let nearClip = 0.01
    let eyeSeparation = Float(0.02)

    var cameraView: UIView?
    var motionManager : CMMotionManager?
    var environmentScene : SCNScene?
    var head : SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMotionManager()
        setupScenes()
    }

    func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
    }

    func setupScenes() {
        environmentScene = SCNScene(named: "Environment.scn")

        leftView?.scene = environmentScene
        rightView?.scene = environmentScene
        leftView?.backgroundColor = .clear
        rightView?.backgroundColor = .clear

        mountCamerasOnHead()

        leftView?.delegate = self

        leftView?.isPlaying = true
        rightView?.isPlaying = true
    }

    func mountCamerasOnHead() {
        let leftCamera = SCNCamera()
        let rightCamera = SCNCamera()

        leftCamera.zFar = farClip
        leftCamera.zNear = nearClip
        rightCamera.zFar = farClip
        rightCamera.zNear = nearClip

        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: -eyeSeparation, y: 0.0, z: 0.0)

        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: +eyeSeparation, y: 0.0, z: 0.0)

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

    func renderer(_ aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        orientHead()
    }

    func orientHead() {
        guard let mm = motionManager, let motion = mm.deviceMotion else { return }

        let currentAttitude = motion.attitude
        let upsideDown = (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight)
        let flipFactor = upsideDown ? -1.0 : 1.0
        let roll = flipFactor * currentAttitude.roll - M_PI_2
        let pitch = flipFactor * currentAttitude.pitch

        head?.eulerAngles.x = Float(roll)
        head?.eulerAngles.z = Float(pitch)
        head?.eulerAngles.y = Float(currentAttitude.yaw)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

