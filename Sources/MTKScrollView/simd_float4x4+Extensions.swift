//
//  simd_float4x4+Extensions.swift
//
//
//  Created by Finn Voorhees on 12/12/2021.
//

import simd
import CoreGraphics

extension simd_float4x4 {
    static func *(_ lhs: simd_float4x4, _ rhs: CGPoint) -> CGPoint {
        let float2 = simd_mul([Float(rhs.x), Float(rhs.y), 0, 1], lhs)
        return CGPoint(x: CGFloat(float2.x), y: CGFloat(float2.y))
    }
}
