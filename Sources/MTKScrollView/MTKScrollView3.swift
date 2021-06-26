//
//  MTKScrollView.swift
//  
//
//  Created by Finn Voorhees on 14/06/2021.
//

import Foundation
import MetalKit
import DisplayLinkAnimation

//open class MTKScrollView: MTKView {
//    public var contentSize = CGSize.zero {
//        didSet {
//            self.setNeedsDisplay(self.bounds)
//        }
//    }
//    
//    public var contentOffset = CGPoint.zero {
//        didSet {
//            self.setNeedsDisplay(self.bounds)
//        }
//    }
//    
//    public var zoomScale: CGFloat = 1 {
//        didSet {
//            self.setNeedsDisplay(self.bounds)
//        }
//    }
//    
//    public var contentBounds: CGRect {
//        let origin = CGPoint(
//            x: self.bounds.midX + self.contentOffset.x - (self.scaledContentSize.width / 2),
//            y: self.bounds.midY + self.contentOffset.y - (self.scaledContentSize.height / 2)
//        )
//        return CGRect(origin: origin, size: self.scaledContentSize)
//    }
//    
//    public var viewTransform: CGAffineTransform {
//        return CGAffineTransform.identity
//            .scaledBy(scale: self.zoomScale)
//            .scaledBy(scale: 2 / self.bounds.size)
//            .translatedBy(delta: self.contentOffset)
//            .translatedBy(delta: -self.contentSize / 2)
//    }
//    
//    public var viewMatrix: simd_float4x4 {
//        return simd_float4x4(self.viewTransform)
//    }
//    
//    private var scaledContentSize: CGSize {
//        return self.contentSize * self.zoomScale
//    }
//    
//    private var contentOffsetBounds: CGRect {
//        let radius = (self.contentSize - (self.bounds.size / self.zoomScale)) / 2
//        return CGRect(
//            x: -max(radius.width, 0),
//            y: -max(radius.height, 0),
//            width: max(radius.width, 0) * 2,
//            height: max(radius.height, 0) * 2
//        )
//    }
//    
//    private var bounceMass: CGFloat = 1
//    private var bounceStiffness: CGFloat = 500
//    
//    public override init(frame frameRect: CGRect, device: MTLDevice?) {
//        super.init(frame: frameRect, device: device)
//        self.commonInit()
//    }
//    
//    public required init(coder: NSCoder) {
//        super.init(coder: coder)
//        self.commonInit()
//    }
//    
//    private func commonInit() {
//        self.isPaused = true
//        self.enableSetNeedsDisplay = true
//    }
//    
//    private var unclampedContentOffset = CGPoint.zero
//    private var ignoreXMomentum = false
//    private var ignoreYMomentum = false
//    private var scrollVelocity: CGPoint?
//    private var previousScrollWheelEvent: NSEvent?
//    private var contentOffsetXAnimation: DisplayLinkAnimation?
//    private var contentOffsetYAnimation: DisplayLinkAnimation?
//    open override func scrollWheel(with event: NSEvent) {
//        if event.phase == .began {
//            self.ignoreXMomentum = false
//            self.ignoreYMomentum = false
//            self.previousScrollWheelEvent = nil
//            self.unclampedContentOffset = self.contentOffset
//            self.contentOffsetXAnimation?.invalidate()
//            self.contentOffsetXAnimation = nil
//            self.contentOffsetYAnimation?.invalidate()
//            self.contentOffsetYAnimation = nil
//        }
//        
//        if event.phase == .changed || event.momentumPhase == .changed {
//            let translation = CGPoint(
//                x: event.scrollingDeltaX / self.zoomScale / (NSScreen.main?.backingScaleFactor ?? 1),
//                y: -event.scrollingDeltaY / self.zoomScale / (NSScreen.main?.backingScaleFactor ?? 1)
//            )
//            if !self.ignoreXMomentum {
//                self.unclampedContentOffset.x += translation.x
//                self.contentOffset.x = self.rubberBandClampedContentOffset(for: self.unclampedContentOffset).x
//            }
//            if !self.ignoreYMomentum {
//                self.unclampedContentOffset.y += translation.y
//                self.contentOffset.y = self.rubberBandClampedContentOffset(for: self.unclampedContentOffset).y
//            }
//            if let previousScrollWheelEvent = self.previousScrollWheelEvent {
//                self.scrollVelocity = translation / (event.timestamp - previousScrollWheelEvent.timestamp)
//            }
//        }
//        
//        if event.phase == .ended || event.momentumPhase == .changed {
//            guard let scrollVelocity = self.scrollVelocity else {
//                return
//            }
//
//            let contentOffsetBounds = self.contentOffsetBounds
//            if (self.contentOffset.x < contentOffsetBounds.minX || self.contentOffset.x > contentOffsetBounds.maxX) && !self.ignoreXMomentum {
//                // Bounce X
//                self.ignoreXMomentum = true
//                let clampedContentOffsetX = self.contentOffset.x.clamped(to: contentOffsetBounds.minX...contentOffsetBounds.maxX)
//                let displacement = self.contentOffset.x - clampedContentOffsetX
//                let spring = Spring(mass: self.bounceMass, stiffness: self.bounceStiffness, displacement: displacement, velocity: scrollVelocity.x)
//                self.contentOffsetXAnimation = DisplayLinkAnimation(duration: spring.duration, animationHandler: { [weak self] _, time in
//                    self?.contentOffset.x = clampedContentOffsetX + spring.value(at: time)
//                })
//            }
//            
//            if (self.contentOffset.y < contentOffsetBounds.minY || self.contentOffset.y > contentOffsetBounds.maxY) && !self.ignoreYMomentum {
//                // Bounce Y
//                self.ignoreYMomentum = true
//                let clampedContentOffsetY = self.contentOffset.y.clamped(to: contentOffsetBounds.minY...contentOffsetBounds.maxY)
//                let displacement = self.contentOffset.y - clampedContentOffsetY
//                let spring = Spring(mass: self.bounceMass, stiffness: self.bounceStiffness, displacement: displacement, velocity: scrollVelocity.y)
//                self.contentOffsetYAnimation = DisplayLinkAnimation(duration: spring.duration, animationHandler: { [weak self] _, time in
//                    self?.contentOffset.y = clampedContentOffsetY + spring.value(at: time)
//                })
//            }
//        }
//        
//        self.previousScrollWheelEvent = event
//    }
//    
//    private func rubberBandClampedContentOffset(for point: CGPoint) -> CGPoint {
//        let xDimension = (self.contentSize.width * self.zoomScale) > self.bounds.width ? self.bounds.width : (self.bounds.width - (self.contentSize.width * self.zoomScale)) / 2
//        let yDimension = (self.contentSize.height * self.zoomScale) > self.bounds.height ? self.bounds.height : (self.bounds.height - (self.contentSize.height * self.zoomScale)) / 2
//        return RubberBand.clamp(
//            point,
//            dimensions: CGSize(width: xDimension, height: yDimension),
//            bounds: self.contentOffsetBounds,
//            coefficient: 0.2
//        )
//    }
//
//    var pointToZoomAround: CGPoint?
//    open override func magnify(with event: NSEvent) {
//        let zoomAmount = 1.0 + event.magnification
//        self.zoomScale *= zoomAmount
//        if event.phase == .began {
//            var location = self.convert(event.locationInWindow, from: nil)
//            if self.contentBounds.contains(location) && (
//                zoomAmount > 1 ||
//                self.scaledContentSize.width > self.bounds.width ||
//                self.scaledContentSize.height > self.bounds.height
//            ) {
//                location -= CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//                location = location / self.zoomScale
////                self.pointToZoomAround = location
//            } else {
//                self.pointToZoomAround = nil
//            }
//        }
//        
////        if let pointToZoomAround = self.pointToZoomAround {
////            self.contentOffset += pointToZoomAround - (pointToZoomAround * zoomAmount)
////            self.unclampedContentOffset = self.contentOffset
////            self.pointToZoomAround = pointToZoomAround + (pointToZoomAround - (pointToZoomAround * zoomAmount))
////        }
//        
//        if event.phase == .ended {
//            let contentOffsetBounds = self.contentOffsetBounds
//            let clampedContentOffset = CGPoint(
//                x: self.contentOffset.x.clamped(to: contentOffsetBounds.minX...contentOffsetBounds.maxX),
//                y: self.contentOffset.y.clamped(to: contentOffsetBounds.minY...contentOffsetBounds.maxY)
//            )
//            if self.contentOffset != clampedContentOffset {
//                let startContentOffset = self.contentOffset
//                self.anim?.invalidate()
//                self.anim = DisplayLinkAnimation(duration: 0.3, animationHandler: { progress, _ in
//                    self.contentOffset = lerp(
//                        from: startContentOffset,
//                        to: clampedContentOffset,
//                        progress: progress,
//                        function: .easeOutCubic
//                    )
//                    print(self.contentOffset)
//                    self.unclampedContentOffset = self.contentOffset
//                })
//            }
//        }
//    }
//    var anim: DisplayLinkAnimation?
//}
