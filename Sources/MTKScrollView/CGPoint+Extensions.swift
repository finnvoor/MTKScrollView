//
//  CGPoint+Extensions.swift
//
//
//  Created by Finn Voorhees on 12/12/2021.
//

import CoreGraphics

extension CGPoint {
    static func /(_ lhs: CGPoint, _ rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
    }
    
    static func *(_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func -(_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    static func +(_ lhs: CGPoint, _ rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
}
