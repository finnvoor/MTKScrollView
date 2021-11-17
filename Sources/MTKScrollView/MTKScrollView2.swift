//
//  MTKScrollView.swift
//
//
//  Created by Finn Voorhees on 26/06/2021.
//
#if os(iOS)

import Foundation
import MetalKit

/// A view that allows the scrolling and zooming of a MTKView, providing a ``viewMatrix`` for use in vertex shaders.
open class MTKScrollView: MTKView {
    /// A Boolean value that determines whether the scroll view content is centered.
    public var shouldCenterContentView = true {
        didSet {
            layoutSubviews()
            setNeedsDisplay()
        }
    }

    /// The size of the scroll view content.
    public var contentSize: CGSize = .zero {
        didSet {
            scrollView.contentSize = contentSize
            contentView.frame.size = contentSize
            updateZoomBounds()
            zoomToFit()
            self.setNeedsDisplay()
        }
    }

    /// An affine transformation matrix mapping between the content vector space and the scrolled, offset, Metal coordinate vector space.
    /// The content vector space has origin (0, 0) and size ``contentSize``.
    /// The scrolled, offset, Metal coordinate vector space applies a scale and offset as well as mapping to the Metal coordinate space (origin: [-1, -1] size: [2, 2]).
    public var viewTransform: CGAffineTransform {
        var contentViewBounds: CGRect!
        if isAnimating,
           let scrollViewPresentationLayer = scrollView.layer.presentation(),
           let contentViewPresentationLayer = contentView.layer.presentation() {
            contentViewBounds = CGRect(
                x: -scrollViewPresentationLayer.bounds.origin.x,
                y: -scrollViewPresentationLayer.bounds.origin.y,
                width: contentViewPresentationLayer.frame.size.width,
                height: contentViewPresentationLayer.frame.size.height
            )
        } else {
            contentViewBounds = CGRect(
                x: -scrollView.contentOffset.x,
                y: -scrollView.contentOffset.y,
                width: scrollView.contentSize.width,
                height: scrollView.contentSize.height
            )
        }
        return CGAffineTransform.identity
            .scaledBy(x: 1, y: -1)
            .translatedBy(x: -1, y: -1)
            .scaledBy(x: 2, y: 2)
            .scaledBy(x: 1 / bounds.width, y: 1 / bounds.height)
            .translatedBy(x: contentViewBounds.minX, y: contentViewBounds.minY)
            .scaledBy(x: contentViewBounds.width, y: contentViewBounds.height)
            .scaledBy(x: 1 / contentSize.width, y: 1 / contentSize.height)
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

    private var scrollView: UIScrollView!
    private var contentView: UIView!

    private var isAnimating = false
    private var animationDisplayLink: CADisplayLink? {
        willSet {
            animationDisplayLink?.invalidate()
            isAnimating = false
        }
    }
    private var animationStartTime: CFTimeInterval!
    private var animationDuration: CFTimeInterval!

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        contentView = UIView(frame: CGRect(origin: .zero, size: contentSize))
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        isPaused = true
        enableSetNeedsDisplay = true
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateZoomBounds()
        if shouldCenterContentView { centerContentView() }
        self.setNeedsDisplay()
    }

    /// Converts a point from the ``MTKScrollView``'s coordinate system to that of the content view.
    public func convertToContentView(_ point: CGPoint) -> CGPoint {
        return convert(point, to: contentView)
    }

    private func centerContentView() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }

    @objc private func animationHandler() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        if elapsed >= animationDuration {
            animationDisplayLink = nil
            isAnimating = false
        }
        setNeedsDisplay()
    }

    private func displayAndCheckForAnimations() {
        if !(scrollView.layer.animationKeys()?.isEmpty ?? true) ||
            !(contentView.layer.animationKeys()?.isEmpty ?? true) {
            let scrollViewAnimationDuration = (scrollView.layer.animationKeys() ?? []).compactMap({
                scrollView.layer.animation(forKey: $0)?.duration
            }).max() ?? 0
            let contentViewAnimationDuration = (contentView.layer.animationKeys() ?? []).compactMap({
                contentView.layer.animation(forKey: $0)?.duration
            }).max() ?? 0
            animationDisplayLink = CADisplayLink(target: self, selector: #selector(animationHandler))
            isAnimating = true
            animationStartTime = CACurrentMediaTime()
            animationDuration = max(scrollViewAnimationDuration, contentViewAnimationDuration)
            animationDisplayLink?.add(to: .current, forMode: .default)
        }
        setNeedsDisplay()
    }
}

extension MTKScrollView {
    /// Zooms to precisely fit the ``contentSize`` in the view's frame.
    public func zoomToFit(animated: Bool = false) {
        scrollView.setZoomScale(min(
            bounds.width / contentSize.width,
            bounds.height / contentSize.height
        ), animated: animated)
    }

    private func updateZoomBounds() {
        let pixelScale = UIScreen.main.scale
        scrollView.minimumZoomScale = min(
            bounds.width / contentSize.width * (2 / 3),
            bounds.height / contentSize.height * (2 / 3)
        )
        scrollView.maximumZoomScale = pixelScale * 50
        scrollView.zoomScale = min(max(scrollView.zoomScale, scrollView.minimumZoomScale), scrollView.maximumZoomScale)
    }
}

extension MTKScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if shouldCenterContentView { centerContentView() }
        displayAndCheckForAnimations()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        displayAndCheckForAnimations()
    }
}
#endif
