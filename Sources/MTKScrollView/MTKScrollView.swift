//
//  MTKScrollView.swift
//  
//
//  Created by Finn Voorhees on 26/06/2021.
//

import Foundation
import MetalKit

/// A view that allows the scrolling and zooming of a MTKView, providing a ``viewMatrix`` for use in vertex shaders.
open class MTKScrollView: MTKView {
    /// A Boolean value that determines whether the scroll view content is centered.
    public var shouldCenterContentView = false {
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
    
    public var viewMatrix: simd_float4x4 {
        return simd_float4x4(viewTransform)
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
    public func zoomToFit(animated: Bool = false) {
        scrollView.setZoomScale(min(
            bounds.width / contentSize.width,
            bounds.height / contentSize.height
        ), animated: animated)
    }
    
    private func updateZoomBounds() {
        let pixelScale = UIScreen.main.scale
        scrollView.minimumZoomScale = min(
            bounds.width / contentSize.width,
            bounds.height / contentSize.height
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
