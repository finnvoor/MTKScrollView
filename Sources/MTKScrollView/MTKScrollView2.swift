//
//  MTKScrollView.swift
//
//
//  Created by Finn Voorhees on 10/06/2021.
//

import MetalKit
import DisplayLinkAnimation

/// A `MTKView` subclass that allows the scrolling and zooming of content by maintaining a ``viewMatrix`` that can be used in vertex shaders.
//open class MTKScrollView: MTKView {
//    /// The size of the MTKScrollView's content.
//    public var contentSize: CGSize = CGSize(width: 40, height: 40) {
//        didSet {
//            self.updateZoomBounds()
//            self.setNeedsDisplay(self.bounds)
//        }
//    }
//
//    /// The distance that the MTKScrollView's content can scroll past the edge of the view when zoomed in.
//    public var overscroll = CGSize(width: 100, height: 100) {
//        didSet {
//            self.updateZoomBounds()
//            self.setNeedsDisplay(self.bounds)
//        }
//    }
//
//    /// The distance between the MTKScrollView's center and the center of its content.
//    public var contentOffset: CGPoint {
//        return self.rubberBandClampedContentOffset
//    }
//    private var rubberBandClampedContentOffset: CGPoint = .zero {
//        didSet { self.setNeedsDisplay(self.bounds) }
//    }
//    private var unclampedContentOffset: CGPoint = .zero
//
//    /// A floating-point value that specifies the current scale factor applied to the MTKScrollView's content.
//    public var zoomScale: CGFloat {
//        return self.rubberBandClampedZoomScale
//    }
//    private var rubberBandClampedZoomScale: CGFloat = 1 {
//        didSet { self.setNeedsDisplay(self.bounds) }
//    }
//    private var unclampedZoomScale: CGFloat = 1
//    /// A floating-point value that specifies the maximum scale factor
//    /// that can be applied to the MTKScrollView's content.
//    public private(set) var maximumZoomScale: CGFloat = 4
//    /// A floating-point value that specifies the minimum scale factor
//    /// that can be applied to the MTKScrollView's content.
//    public private(set) var minimumZoomScale: CGFloat = 0.5
//
//    private var zoomAnimation: DisplayLinkAnimation?
//    private var zoomBounceAnimation: DisplayLinkAnimation?
//    private var contentOffsetBounceAnimation: DisplayLinkAnimation?
//
//    /// The Metal view matrix derived from the view's `frame`, ``contentSize``, ``zoomScale`` and ``contentOffset``.
//    public var viewMatrix: simd_float4x4 {
//        return simd_float4x4(
//            CGAffineTransform.identity
//                .scaledBy(scale: 2)
//                .scaledBy(scale: self.zoomScale)
//                .scaledBy(scale: self.contentSize / self.frame.size)
//                .scaledBy(scale: 1 / self.contentSize)
//                .translatedBy(delta: self.contentOffset)
//                .translatedBy(delta: -self.contentSize / 2)
//        )
//    }
//
//    /// Initializes a view with the specified frame rectangle and Metal device.
//    /// - Parameters:
//    ///   - frameRect: The frame rectangle for the view.
//    ///   - device: The Metal device object to use.
//    /// - Returns: An initialized view object.
//    public override init(frame frameRect: CGRect, device: MTLDevice?) {
//        super.init(frame: frameRect, device: device)
//        self.sharedInit()
//    }
//
//    /// Initializes a view from data in a given unarchiver.
//    /// - Parameter coder: An unarchiver object.
//    /// - Returns: An initialized view object.
//    public required init(coder: NSCoder) {
//        super.init(coder: coder)
//        self.sharedInit()
//    }
//
//    private func sharedInit() {
//        #if os(iOS)
//        let pinchGestureRecognizer = UIPinchGestureRecognizer(
//            target: self,
//            action: #selector(self.handlePinch(from:))
//        )
//        pinchGestureRecognizer.delegate = self
//        self.addGestureRecognizer(pinchGestureRecognizer)
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(from:)))
//        panGestureRecognizer.delegate = self
//        panGestureRecognizer.minimumNumberOfTouches = 2
//        self.addGestureRecognizer(panGestureRecognizer)
//        #endif
//        self.isPaused = true
//        self.enableSetNeedsDisplay = true
//        self.updateZoomBounds()
//    }
//
//    #if os(iOS)
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        self.updateZoomBounds()
////        self.rubberBandClampedContentOffset = self.rubberBandClampedContentOffset
//        self.unclampedContentOffset = self.rubberBandClampedContentOffset
//    }
//    #else
//    public override func layout() {
//        super.layout()
//        self.rubberBandClampedContentOffset = self.clampedContentOffset()
//        self.unclampedContentOffset = self.rubberBandClampedContentOffset
//    }
//    #endif
//
//    private func contentOffsetBounds(for zoomScale: CGFloat? = nil) -> CGSize {
//        let overscroll = (
//            self.contentSize.width * (zoomScale ?? self.zoomScale) > self.bounds.width ||
//            self.contentSize.height * (zoomScale ?? self.zoomScale) > self.bounds.height
//        ) ? self.overscroll : .zero
//        var bounds = (self.contentSize - ((self.frame.size - overscroll) / (zoomScale ?? self.zoomScale))) / 2
//        bounds.width = max(bounds.width, 0)
//        bounds.height = max(bounds.height, 0)
//        return bounds
//    }
//
//    private func clampedContentOffset(for zoomScale: CGFloat? = nil) -> CGPoint {
//        let bounds = self.contentOffsetBounds(for: zoomScale)
//        return CGPoint(
//            x: self.unclampedContentOffset.x.clamped(to: -bounds.width...bounds.width),
//            y: self.unclampedContentOffset.y.clamped(to: -bounds.height...bounds.height)
//        )
//    }
//
//    // MARK: - Zoom
//
//    /// Zooms the ScrollableMTKView to a scale that fits the content exactly
//    public func zoomToFit(animated: Bool = true) {
//        self.zoomAnimation = nil
//        let optimalZoomScale = min(
//            self.frame.width / self.contentSize.width,
//            self.frame.height / self.contentSize.height
//        )
//        let currentZoomScale = self.zoomScale
//        let optimalContentOffset = self.clampedContentOffset(for: optimalZoomScale)
//        let currentContentOffset = self.contentOffset
//        if animated, let animation = DisplayLinkAnimation(duration: 0.3, animationHandler: { (progress, _) in
//            self.rubberBandClampedZoomScale = lerp(
//                from: currentZoomScale,
//                to: optimalZoomScale,
//                progress: progress,
//                function: .easeOutCubic
//            )
//            self.rubberBandClampedContentOffset = lerp(
//                from: currentContentOffset,
//                to: optimalContentOffset,
//                progress: progress,
//                function: .easeOutCubic
//            )
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }) {
//            self.zoomAnimation = animation
//        } else {
//            self.rubberBandClampedZoomScale = optimalZoomScale
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }
//    }
//
//    /// The multiplier to use for calls to `zoomIn()` and `zoomOut()`
//    public var zoomIncrement: CGFloat = 1.75
//
//    /// Zooms the ScrollableMTKView in by a factor of `zoomIncrement`
//    public func zoomIn(animated: Bool = true) {
//        self.zoomAnimation = nil
//        let optimalZoomScale = min(self.maximumZoomScale, self.zoomScale * self.zoomIncrement)
//        let currentZoomScale = self.zoomScale
//        if animated, let animation = DisplayLinkAnimation(duration: 0.2, animationHandler: { (progress, _) in
//            self.rubberBandClampedZoomScale = lerp(
//                from: currentZoomScale,
//                to: optimalZoomScale,
//                progress: progress,
//                function: .easeOutCubic
//            )
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }, completionHandler: { (_) in
//            self.rubberBandClampedZoomScale = optimalZoomScale
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }) {
//            self.zoomAnimation = animation
//        } else {
//            self.rubberBandClampedZoomScale = optimalZoomScale
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }
//    }
//
//    /// Zooms the ScrollableMTKView out by a factor of `zoomIncrement`
//    public func zoomOut(animated: Bool = true) {
//        self.zoomAnimation = nil
//        let optimalZoomScale = max(self.minimumZoomScale, self.zoomScale / self.zoomIncrement)
//        let currentZoomScale = self.zoomScale
//        if animated, let animation = DisplayLinkAnimation(duration: 0.2, animationHandler: { (progress, _) in
//            self.rubberBandClampedZoomScale = lerp(
//                from: currentZoomScale,
//                to: optimalZoomScale,
//                progress: progress,
//                function: .easeOutCubic
//            )
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }, completionHandler: { (_) in
//            self.rubberBandClampedZoomScale = optimalZoomScale
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }) {
//            self.zoomAnimation = animation
//        } else {
//            self.rubberBandClampedZoomScale = optimalZoomScale
//            self.rubberBandClampedContentOffset = self.clampedContentOffset()
//            self.unclampedZoomScale = self.zoomScale
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//        }
//    }
//
//    private func updateZoomBounds() {
//        #if os(iOS)
//        let pixelScale = UIScreen.main.scale
//        self.minimumZoomScale = min(
//            (self.frame.width - self.overscroll.width) / self.contentSize.width,
//            (self.frame.height - self.overscroll.height) / self.contentSize.height
//        )
//        #else
//        let pixelScale = NSScreen.main?.backingScaleFactor ?? 2.0
//        self.minimumZoomScale = (pixelScale * 50) / max(self.contentSize.width, self.contentSize.height)
//        #endif
//        self.maximumZoomScale = (pixelScale * 50)
//        self.rubberBandClampedZoomScale = self.zoomScale.clamped(to: self.minimumZoomScale...self.maximumZoomScale)
//    }
//
//    private var shouldZoomAroundPoint = false
//    private var pointToZoomAround: CGPoint = .zero
//    private func zoom(by amount: CGFloat, around point: CGPoint, began: Bool, ended: Bool) {
//        if began {
//            self.unclampedZoomScale = self.zoomScale
//            self.pointToZoomAround = point
//            self.shouldZoomAroundPoint = CGRect(
//                origin: self.contentOffset - CGPoint(x: self.contentSize.width / 2, y: self.contentSize.height / 2),
//                size: self.contentSize
//            ).contains(point) && (
//                amount > 1 ||
//                self.contentSize.width * self.zoomScale > self.bounds.width ||
//                self.contentSize.height * self.zoomScale > self.bounds.height
//            )
//        }
//
//        self.unclampedZoomScale *= amount
//        let clampedZoom = self.unclampedZoomScale.clamped(to: self.minimumZoomScale...self.maximumZoomScale)
//        let difference = abs(self.unclampedZoomScale - clampedZoom)
//        let sign = sign(self.unclampedZoomScale - clampedZoom)
//        self.rubberBandClampedZoomScale = clampedZoom + (sign * rubberBandClamp(
//            difference,
//            coefficient: 0.55,
//            dimension: (sign > 0 ? self.maximumZoomScale : self.minimumZoomScale) / 4
//        ))
//
//        if self.zoomScale == clampedZoom,
//           self.shouldZoomAroundPoint {
//            self.rubberBandClampedContentOffset += (self.pointToZoomAround - (self.pointToZoomAround * amount))
//            self.unclampedContentOffset = self.rubberBandClampedContentOffset
//            self.pointToZoomAround += (self.pointToZoomAround - (self.pointToZoomAround * amount))
//            #if os(iOS)
////            let rubberBandClampedContentOffset = self.rubberBandClampedContentOffset()
//            self.pointToZoomAround += (rubberBandClampedContentOffset - self.contentOffset)
////            self.contentOffset = rubberBandClampedContentOffset
//            #endif
//        }
//
//        if ended {
//            // zoomBounceAnimation
//            if self.zoomScale != clampedZoom {
//                let finishedZoom = self.zoomScale
//                if let animation = DisplayLinkAnimation(duration: 0.3, animationHandler: { (progress, _) in
//                    self.rubberBandClampedZoomScale = lerp(
//                        from: finishedZoom,
//                        to: clampedZoom,
//                        progress: progress,
//                        function: .easeOutCubic
//                    )
//                }) {
//                    self.zoomBounceAnimation = animation
//                } else {
//                    self.rubberBandClampedZoomScale = clampedZoom
//                }
//            }
//
//            let clampedContentOffset = self.clampedContentOffset(for: clampedZoom)
//            // contentOffsetBounceAnimation
//            if self.contentOffset != clampedContentOffset {
//                let finishedContentOffset = self.contentOffset
//                if let animation = DisplayLinkAnimation(duration: 0.3, animationHandler: { (progress, _) in
//                    self.rubberBandClampedContentOffset = lerp(
//                        from: finishedContentOffset,
//                        to: clampedContentOffset,
//                        progress: progress,
//                        function: .easeOutCubic
//                    )
//                    self.unclampedContentOffset = self.rubberBandClampedContentOffset
//                }) {
//                    self.contentOffsetBounceAnimation = animation
//                } else {
//                    self.rubberBandClampedContentOffset = clampedContentOffset
//                    self.unclampedContentOffset = self.rubberBandClampedContentOffset
//                }
//            }
//        }
//    }
//
//    #if os(iOS)
//    @objc private func handlePinch(from gestureRecognizer: UIPinchGestureRecognizer) {
//        var location = gestureRecognizer.location(in: self)
//        location -= CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//        location.y = -location.y
//        self.zoom(
//            by: gestureRecognizer.scale,
//            around: location / self.zoomScale,
//            began: gestureRecognizer.state == .began,
//            ended: gestureRecognizer.state == .ended
//        )
//        gestureRecognizer.scale = 1
//    }
//
//    #else
//
//    public override func magnify(with event: NSEvent) {
//        if event.phase == .began {
//            self.zoomBounceAnimation = nil
//        }
//        var location = self.convert(event.locationInWindow, from: nil)
//        location -= CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//        self.zoom(
//            by: 1 + event.magnification,
//            around: location / self.zoomScale,
//            began: event.phase == .began,
//            ended: event.phase == .ended
//        )
//    }
//    #endif
//
//    // MARK: - Pan
//    private func pan(by delta: CGPoint, began: Bool, ended: Bool, momentum: Bool) {
//        if began {
//            self.unclampedContentOffset = self.contentOffset
//        }
//
//        self.unclampedContentOffset += delta
//        let clampedContentOffset = self.clampedContentOffset()
//        let difference = abs(self.unclampedContentOffset - clampedContentOffset)
//        let sign = sign(self.unclampedContentOffset - clampedContentOffset)
//        let bounds = self.contentOffsetBounds()
//        self.rubberBandClampedContentOffset.x = clampedContentOffset.x + (sign.x * rubberBandClamp(
//            difference.x,
//            coefficient: 0.55,
//            dimension: max(bounds.width / 2, 5)
//        ))
//        self.rubberBandClampedContentOffset.y = clampedContentOffset.y + (sign.y * rubberBandClamp(
//            difference.y,
//            coefficient: 0.55,
//            dimension: max(bounds.height / 2, 5)
//        ))
//
//        if ended || momentum {
//            let clampedContentOffset = self.clampedContentOffset()
//            // contentOffsetBounceAnimation
//            if self.contentOffset != clampedContentOffset {
//                let finishedContentOffset = self.contentOffset
//                if let animation = DisplayLinkAnimation(duration: 0.3, animationHandler: { (progress, _) in
//                    self.rubberBandClampedContentOffset = lerp(
//                        from: finishedContentOffset,
//                        to: clampedContentOffset,
//                        progress: progress,
//                        function: .easeOutCubic
//                    )
//                    self.unclampedContentOffset = self.rubberBandClampedContentOffset
//                }) {
//                    self.contentOffsetBounceAnimation = animation
//                } else {
//                    self.rubberBandClampedContentOffset = clampedContentOffset
//                    self.unclampedContentOffset = self.rubberBandClampedContentOffset
//                }
//            }
//        }
//    }
//
//    #if os(iOS)
//    @objc private func handlePan(from gestureRecognizer: UIPanGestureRecognizer) {
//        let translation = gestureRecognizer.translation(in: self)
//        self.pan(
//            by: translation / self.zoomScale
//        )
//        gestureRecognizer.setTranslation(.zero, in: self)
//    }
//
//    #else
//
//    public override func scrollWheel(with event: NSEvent) {
//        if event.phase == .began {
//            self.contentOffsetBounceAnimation = nil
//        }
//        guard self.contentOffsetBounceAnimation == nil else { return }
//        self.pan(
//            by: CGPoint(
//                x: event.scrollingDeltaX / self.zoomScale / (NSScreen.main?.backingScaleFactor ?? 1),
//                y: -event.scrollingDeltaY / self.zoomScale / (NSScreen.main?.backingScaleFactor ?? 1)
//            ),
//            began: event.phase == .began,
//            ended: event.phase == .ended,
//            momentum: event.momentumPhase == .changed
//        )
//    }
//    #endif
//}
//
//// MARK: - UIGestureRecognizerDelegate
//#if os(iOS)
//extension MTKScrollView: UIGestureRecognizerDelegate {
//    public func gestureRecognizer(
//        _ gestureRecognizer: UIGestureRecognizer,
//        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
//    ) -> Bool {
//        return true
//    }
//}
//#endif
