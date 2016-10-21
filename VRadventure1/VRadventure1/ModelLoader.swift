//
//  ModelLoader.swift
//  VRadventure1
//
//  Created by Ted Goddard on 2016-09-08.
//  Copyright © 2016 Robots & Pencils. All rights reserved.
//

import Foundation
import SceneKit
import SceneKit.ModelIO

class ModelLoader {
    let environmentScene: SCNScene?
    var fanRadius = Double(4)
    var modelClamp = Float(2)

    init(environmentScene: SCNScene?) {
        self.environmentScene = environmentScene
    }

    func addAssortedMesh() {
        let daeURLs = Bundle.main.urls(forResourcesWithExtension: "dae", subdirectory: "VRassets.scnassets")
        let objURLs = Bundle.main.urls(forResourcesWithExtension: "obj", subdirectory: "VRassets.scnassets")

        var modelURLs: [URL] = []
        modelURLs += daeURLs ?? []
        modelURLs += objURLs ?? []

        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let userURLs = (try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: []))
            modelURLs += userURLs ?? []
        }

        for (index, modelURL) in modelURLs.enumerated() {
            //partition arc equally and count endpoints to balance it
            let theta = Double(index + 1) / Double(modelURLs.count + 2) * M_PI * 2
            let fanPosition = SCNVector3(x: -1 * Float(fanRadius * sin(theta)), y: 1.0, z: Float(fanRadius * cos(theta)))
            let importedModel = clampAndPlaceModel(url: modelURL, atPosition: fanPosition)
            debugBubble(modelNode: importedModel)
        }
    }

    func clampAndPlaceModel(url: URL, atPosition: SCNVector3) -> SCNNode? {
        let modelScene = try? SCNScene(url: url, options: nil)
        guard let sceneRoot = modelScene?.rootNode else {
            print("import FAIL \(url)")
            return nil
        }
        guard let modelNode = sceneRoot.childNodes.first else { return nil }
        modelNode.name = url.lastPathComponent
        let (modelCenter, modelRadius) = modelNode.boundingSphere
        if (modelRadius > modelClamp) {
            modelNode.scale = scale(SCNVector3(x: 1, y: 1, z: 1), modelClamp / modelRadius)
        }
        modelNode.position = atPosition
        print("added model \(modelNode.name) \(atPosition)")
        environmentScene?.rootNode.addChildNode(modelNode)
        return modelNode
    }

    func debugBubble(modelNode: SCNNode?, color: UIColor = .green) {
        guard let modelNode = modelNode else { return }
        let sphere = SCNNode()
        sphere.geometry = SCNSphere(radius: CGFloat(modelNode.boundingSphere.radius))
        sphere.position = modelNode.boundingSphere.center
        sphere.geometry?.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.5)
        modelNode.addChildNode(sphere)
    }

    func debugBox(modelNode: SCNNode?, color: UIColor = .green) {
        guard let modelNode = modelNode else { return }
        let boxNode = SCNNode()
        let boundingBoxEnds = modelNode.boundingBox

        let boundingBox = SCNBox()
        let boundingDelta = sum(boundingBoxEnds.max, scale(boundingBoxEnds.min, -1))
        boundingBox.width = CGFloat(boundingDelta.x)
        boundingBox.height = CGFloat(boundingDelta.y)
        boundingBox.length = CGFloat(boundingDelta.z)
        boxNode.geometry = boundingBox

        boxNode.position = sum(boundingBoxEnds.min, scale(boundingDelta, 0.5))
        boxNode.geometry?.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.5)
        modelNode.addChildNode(boxNode)
    }

}
