////
////  RubberBand.swift
////  
////
////  Created by Finn Voorhees on 14/06/2021.
////
//
//import Foundation
//import simd
//
///// A set of utility methods for constraining values to bounds with a rubber band effect similar to `UIScrollView`.
//public enum RubberBand {
//    /// Returns a point clamped to the specified bounds with a rubber band effect.
//    /// - Parameters:
//    ///   - point: The point to clamp.
//    ///   - dimensions: The dimensions.
//    ///   - bounds: The bounds to start clamping at.
//    ///   - coefficient: The coefficient ratio (default is 0.55).
//    /// - Returns: The clamped point.
//    public static func clamp(_ point: CGPoint, dimensions: CGSize, bounds: CGRect, coefficient: CGFloat = 0.55) -> CGPoint {
//        let clampedX = RubberBand.clamp(point.x, dimension: dimensions.width, limits: bounds.minX...bounds.maxX, coefficient: coefficient)
//        let clampedY = RubberBand.clamp(point.y, dimension: dimensions.height, limits: bounds.minY...bounds.maxY, coefficient: coefficient)
//        return CGPoint(x: clampedX, y: clampedY)
//    }
//    
//    /// Returns a value clamped to the specified bounds with a rubber band effect.
//    /// - Parameters:
//    ///   - value: The value to clamp.
//    ///   - dimensions: The dimensions.
//    ///   - bounds: The bounds to start clamping at.
//    ///   - coefficient: The coefficient ratio (default is 0.55).
//    /// - Returns: The clamped value.
//    public static func clamp(_ value: CGFloat, dimension: CGFloat, limits: ClosedRange<CGFloat>, coefficient: CGFloat = 0.55) -> CGFloat {
//        let clampedValue = value.clamped(to: limits)
//        let difference = abs(value - clampedValue)
//        let sign = sign(value - clampedValue)
//        return clampedValue + sign * RubberBand.clamp(difference, dimension: dimension, coefficient: coefficient)
//    }
//    
//    /// Equation from [twitter.com/chpwn](https://twitter.com/chpwn/status/285540192096497664)
//    private static func clamp(_ value: CGFloat, dimension: CGFloat, coefficient: CGFloat) -> CGFloat {
//        return (1.0 - (1.0 / (value * coefficient / dimension + 1.0))) * dimension
//    }
//}
