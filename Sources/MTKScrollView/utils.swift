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
        let caTransform = CATransform3DMakeAffineTransform(transform)
        self = simd_float4x4([
            [Float(caTransform.m11), Float(caTransform.m12), Float(caTransform.m13), Float(caTransform.m14)],
            [Float(caTransform.m21), Float(caTransform.m22), Float(caTransform.m23), Float(caTransform.m24)],
            [Float(caTransform.m31), Float(caTransform.m32), Float(caTransform.m33), Float(caTransform.m34)],
            [Float(caTransform.m41), Float(caTransform.m42), Float(caTransform.m43), Float(caTransform.m44)]
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
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGSize {
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func / (lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs / rhs.width, height: lhs / rhs.height)
    }

    static prefix func - (lhs: CGSize) -> CGSize {
        return CGSize(width: -lhs.width, height: -lhs.height)
    }
}

/// Equation from [twitter.com/chpwn](https://twitter.com/chpwn/status/285540192096497664)
func rubberBandClamp(_ value: CGFloat, coefficient: CGFloat, dimension: CGFloat) -> CGFloat {
    return (1.0 - (1.0 / ((value * coefficient / dimension) + 1.0))) * dimension
}

func abs(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: abs(point.x), y: abs(point.y))
}

func sign(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: sign(point.x), y: sign(point.y))
}
