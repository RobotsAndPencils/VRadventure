//
//  VectorUtilities.swift
//  VRadventure1
//
//  Created by Ted Goddard on 2016-09-08.
//  Copyright © 2016 Robots & Pencils. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    func sum(_ otherVector: SCNVector3) -> SCNVector3 {
        return SCNVector3FromGLKVector3(GLKVector3Add(SCNVector3ToGLKVector3(self), SCNVector3ToGLKVector3(otherVector)))
    }

    func distance(_ otherVector: SCNVector3) -> Float {
        return GLKVector3Distance(SCNVector3ToGLKVector3(self), SCNVector3ToGLKVector3(otherVector))
    }

    func multiply(_ matrix: SCNMatrix4) -> SCNVector3 {
        return SCNVector3FromGLKVector3(GLKMatrix4MultiplyVector3(SCNMatrix4ToGLKMatrix4(matrix), SCNVector3ToGLKVector3(self)))
    }

    func scale(_ factor: Float) -> SCNVector3 {
        return SCNVector3(x: x * factor, y: y * factor, z: z * factor)
    }
}
