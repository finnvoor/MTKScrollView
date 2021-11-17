//
//  MTKScrollView.swift
//  
//
//  Created by Finn Voorhees on 16/11/2021.
//
#if os(macOS)

import Combine
import MetalKit

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
                x: 2 / scrollView.documentVisibleRect.width * maxPixelSize,
                y: 2 / scrollView.documentVisibleRect.height * maxPixelSize
            )
            .translatedBy(
                x: -scrollView.documentVisibleRect.midX / maxPixelSize,
                y: -scrollView.documentVisibleRect.midY / maxPixelSize
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

    private var maxPixelSize: CGFloat = 10 {
        didSet { updateContentSizeAndScale() }
    }
    private let documentView = NSView()
    private let scrollView = NSScrollView()
    
    private var boundsDidChangeCancellable: AnyCancellable?
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
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
            width: contentSize.width * maxPixelSize,
            height: contentSize.height * maxPixelSize
        )
        let fittingMagnification = min(
            bounds.width / (documentView.bounds.size.width),
            bounds.height / (documentView.bounds.size.height)
        )
        scrollView.maxMagnification = 1
        scrollView.minMagnification = min(fittingMagnification / 2, 1)
    }
    
    open override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        updateContentSizeAndScale()
    }
    
    public func zoomToFit(animated: Bool = false) {
        (animated ? scrollView.animator() : scrollView).magnification = min(min(
            bounds.width / (documentView.bounds.size.width),
            bounds.height / (documentView.bounds.size.height)
        ), 1)
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
