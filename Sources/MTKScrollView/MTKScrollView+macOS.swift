//
//  MTKScrollView.swift
//  
//
//  Created by Finn Voorhees on 16/11/2021.
//
#if os(macOS)

import Combine
import MetalKit

fileprivate class NSFlippedView: NSView { override var isFlipped: Bool { true } }

open class MTKScrollView: MTKView {
    /// The size of the scroll view content.
    public var contentSize: CGSize = CGSize(width: 300, height: 200) {
        didSet { updateContentSizeAndScale() }
    }
    
    /// An affine transformation matrix mapping between the content vector space and the scrolled, offset, Metal coordinate vector space.
    /// The content vector space has origin (0, 0) and size ``contentSize``.
    /// The scrolled, offset, Metal coordinate vector space applies a scale and offset as well as mapping to the Metal coordinate space (origin: [-1, -1] size: [2, 2]).
    public var viewTransform: CGAffineTransform {
        return CGAffineTransform.identity
            .scaledBy(
                x: 2 / scrollView.documentVisibleRect.width * maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1),
                y: 2 / scrollView.documentVisibleRect.height * maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1)
            )
            .scaledBy(x: 1, y: -1)
            .translatedBy(
                x: -scrollView.documentVisibleRect.midX / (maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1)),
                y: -scrollView.documentVisibleRect.midY / (maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1))
            )
    }

    /// A `simd_float4x4` matrix mapping between the content vector space and the scrolled, offset, Metal coordinate vector space.
    /// See ``viewTransform`` for more info.
    public var viewMatrix: simd_float4x4 {
        let caTransform = CATransform3DMakeAffineTransform(viewTransform)
        return simd_float4x4([
            [Float(caTransform.m11), Float(caTransform.m12), Float(caTransform.m13), Float(caTransform.m14)],
            [Float(caTransform.m21), Float(caTransform.m22), Float(caTransform.m23), Float(caTransform.m24)],
            [Float(caTransform.m31), Float(caTransform.m32), Float(caTransform.m33), Float(caTransform.m34)],
            [Float(caTransform.m41), Float(caTransform.m42), Float(caTransform.m43), Float(caTransform.m44)]
        ])
    }
    
    public var magnification: CGFloat { return scrollView.magnification }
    public var minMagnification: CGFloat { return scrollView.minMagnification }
    public var maxMagnification: CGFloat { return scrollView.maxMagnification }
    public var magnificationFactor: CGFloat = 1.5
    public var fittingMagnification: CGFloat {
        return min(
            bounds.width / (documentView.bounds.size.width),
            bounds.height / (documentView.bounds.size.height)
        )
    }

    private var maxPixelSize: CGFloat = 20 {
        didSet { updateContentSizeAndScale() }
    }
    private let documentView = NSFlippedView()
    private let scrollView = NSScrollView()
    
    private var boundsDidChangeCancellable: AnyCancellable?
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupDocumentView()
        setupScrollView()
        updateContentSizeAndScale()
        
        isPaused = true
        enableSetNeedsDisplay = true
    }
    
    private func setupDocumentView() {
        documentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupScrollView() {
        scrollView.allowsMagnification = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.contentView = CenteredClipView()
        scrollView.contentView.postsBoundsChangedNotifications = true
        boundsDidChangeCancellable = NotificationCenter.default.publisher(
            for: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        ).sink { [weak self] _ in self?.setNeedsDisplay(self?.bounds ?? .zero) }
        scrollView.documentView = documentView
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        scrollView.drawsBackground = false
    }
    
    private func updateContentSizeAndScale() {
        documentView.frame.size = CGSize(
            width: contentSize.width * maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1),
            height: contentSize.height * maxPixelSize * (NSScreen.main?.backingScaleFactor ?? 1)
        )
        scrollView.maxMagnification = 1
        scrollView.minMagnification = min(fittingMagnification / 2, 1)
    }
    
    open override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        updateContentSizeAndScale()
    }
    
    public func zoomToFit(animated: Bool = false) {
        (animated ? scrollView.animator() : scrollView).magnification = fittingMagnification
    }
    
    public func zoomIn(animated: Bool = false) {
        (animated ? scrollView.animator() : scrollView).magnification *= magnificationFactor
    }
    
    public func zoomOut(animated: Bool = false) {
        (animated ? scrollView.animator() : scrollView).magnification /= magnificationFactor
    }
    
    /// Converts a point from the ``MTKScrollView``'s coordinate system to that of the canvas..
    public func convertToCanvas(_ point: CGPoint) -> CGPoint {
        let point = convert(point, to: documentView)
        return CGPoint(
            x: point.x / maxPixelSize / (NSScreen.main?.backingScaleFactor ?? 1),
            y: point.y / maxPixelSize / (NSScreen.main?.backingScaleFactor ?? 1)
        )
    }
}

fileprivate class CenteredClipView: NSClipView {
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        if let documentView = documentView {
            if (rect.size.width > documentView.frame.size.width) {
                rect.origin.x = (documentView.frame.width - rect.width) / 2
            }
            if(rect.size.height > documentView.frame.size.height) {
                rect.origin.y = (documentView.frame.height - rect.height) / 2
            }
        }
        return rect
    }
}
#endif
