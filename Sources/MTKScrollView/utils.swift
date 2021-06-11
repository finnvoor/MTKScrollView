//
//  utils.swift
//  
//
//  Created by Finn Voorhees on 10/06/2021.
//

import QuartzCore
import simd

extension simd_float4x4 {
    init(_ transform: CGAffineTransform) {
        let t = CATransform3DMakeAffineTransform(transform)
        self = simd_float4x4([
            [Float(t.m11), Float(t.m12), Float(t.m13), Float(t.m14)],
            [Float(t.m21), Float(t.m22), Float(t.m23), Float(t.m24)],
            [Float(t.m31), Float(t.m32), Float(t.m33), Float(t.m34)],
            [Float(t.m41), Float(t.m42), Float(t.m43), Float(t.m44)]
        ])
    }
}

extension CGAffineTransform {
    func translatedBy(delta: CGPoint) -> CGAffineTransform {
        return self.translatedBy(x: delta.x, y: delta.y)
    }
    
    func translatedBy(delta: CGSize) -> CGAffineTransform {
        return self.translatedBy(x: delta.width, y: delta.height)
    }
    
    func scaledBy(scale: CGFloat) -> CGAffineTransform {
        return self.scaledBy(x: scale, y: scale)
    }
    
    func scaledBy(scale: CGSize) -> CGAffineTransform {
        return self.scaledBy(x: scale.width, y: scale.height)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGSize {
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func /(lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs / rhs.width, height: lhs / rhs.height)
    }
    
    static prefix func -(lhs: CGSize) -> CGSize {
        return CGSize(width: -lhs.width, height: -lhs.height)
    }
}

/// Equation from [twitter.com/chpwn](https://twitter.com/chpwn/status/285540192096497664)
func rubberBandClamp(_ x: CGFloat, coefficient: CGFloat, dimension: CGFloat) -> CGFloat {
    return (1.0 - (1.0 / ((x * coefficient / max(dimension, 0.001)) + 1.0))) * max(dimension, 0.001)
}

func abs(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: abs(point.x), y: abs(point.y))
}

func sign(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: sign(point.x), y: sign(point.y))
}
