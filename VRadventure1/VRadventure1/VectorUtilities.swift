//
//  VectorUtilities.swift
//  VRadventure1
//
//  Created by Ted Goddard on 2016-09-08.
//  Copyright © 2016 Robots & Pencils. All rights reserved.
//

import Foundation
import SceneKit

func sum(_ vectorLeft: SCNVector3, _ vectorRight: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKVector3Add(SCNVector3ToGLKVector3(vectorLeft), SCNVector3ToGLKVector3(vectorRight)))
}

func distance(_ vectorLeft: SCNVector3, _ vectorRight: SCNVector3) -> Float {
    return GLKVector3Distance(SCNVector3ToGLKVector3(vectorLeft), SCNVector3ToGLKVector3(vectorRight))
}

func multiply(_ matrixLeft: SCNMatrix4, _ vectorRight: SCNVector3) -> SCNVector3 {
    return SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(SCNMatrix4ToGLKMatrix4(matrixLeft), SCNVector3ToGLKVector3(vectorRight)))
}

func scale(_ vectorLeft: SCNVector3, _ factor: Float) -> SCNVector3 {
    return SCNVector3(x: vectorLeft.x * factor, y: vectorLeft.y * factor, z: vectorLeft.z * factor)
}
