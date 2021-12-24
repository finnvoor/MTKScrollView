//
//  CGSize+Extensions.swift
//
//
//  Created by Finn Voorhees on 12/12/2021.
//

import CoreGraphics

extension CGSize {
    static func /(_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
