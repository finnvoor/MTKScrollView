//
//  Spring.swift
//  
//
//  Created by Finn Voorhees on 14/06/2021.
//

import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

//public struct Spring {
//    private let mass: CGFloat
//    private let stiffness: CGFloat
//    private let displacement: CGFloat
//    private let velocity: CGFloat
//    
//    public var duration: TimeInterval {
//        guard !(self.displacement == 0 && self.velocity == 0) else {
//            return 0
//        }
//        
//        let damping = 2 * sqrt(self.mass * self.stiffness)
//        let beta = damping / (2 * self.mass)
//        let euler = CGFloat(M_E)
//        let threshold = 0.5 / (NSScreen.main?.backingScaleFactor ?? 1)
//        
//        let time1 = (1 / beta) * log(2 * self.displacement / threshold)
//        let time2 = (2 / beta) * log(4 * (self.velocity + (beta * self.displacement)) / (euler * beta * threshold))
//        
//        return max(time1, time2)
//    }
//
//    public init(mass: CGFloat, stiffness: CGFloat, displacement: CGFloat, velocity: CGFloat) {
//        self.mass = mass
//        self.stiffness = stiffness
//        self.displacement = displacement
//        self.velocity = velocity
//    }
//    
//    public func value(at time: TimeInterval) -> CGFloat {
//        let damping = 2 * sqrt(self.mass * self.stiffness)
//        let beta = damping / (2 * self.mass)
//        return exp(-beta * time) * (self.displacement + ((self.velocity + (beta * self.displacement)) * time))
//    }
//}
