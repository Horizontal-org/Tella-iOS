//
//  ZoomableMediaView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import UIKit

final class ZoomableMediaView: UIScrollView, UIScrollViewDelegate {

    let mediaView: UIView

    var isZoomEnabled = true {
        didSet {
            guard isZoomEnabled != oldValue else { return }
            pinchGestureRecognizer?.isEnabled = isZoomEnabled
            doubleTapGesture.isEnabled = isZoomEnabled
            if !isZoomEnabled {
                resetZoom(animated: false)
            }
        }
    }

    private var viewportSize = CGSize.zero

    private lazy var doubleTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleDoubleTap(_:))
    )

    init(mediaView: UIView) {
        self.mediaView = mediaView
        super.init(frame: .zero)

        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 5
        bouncesZoom = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .clear

        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        addSubview(mediaView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.size != viewportSize else { return }

        viewportSize = bounds.size
        resetZoom(animated: false)
        mediaView.frame = CGRect(origin: .zero, size: bounds.size)
        contentSize = bounds.size
        contentInset = .zero
        contentOffset = .zero
    }

    func viewForZooming(in _: UIScrollView) -> UIView? {
        isZoomEnabled ? mediaView : nil
    }

    func scrollViewDidZoom(_: UIScrollView) {
        let horizontalInset = max(0, (bounds.width - contentSize.width) / 2)
        let verticalInset = max(0, (bounds.height - contentSize.height) / 2)
        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    func resetZoom(animated: Bool) {
        setZoomScale(minimumZoomScale, animated: animated)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if zoomScale > minimumZoomScale {
            resetZoom(animated: true)
            return
        }

        let targetScale: CGFloat = 2.5
        let point = gesture.location(in: mediaView)
        let targetSize = CGSize(
            width: bounds.width / targetScale,
            height: bounds.height / targetScale
        )
        let targetRect = CGRect(
            x: point.x - targetSize.width / 2,
            y: point.y - targetSize.height / 2,
            width: targetSize.width,
            height: targetSize.height
        )

        zoom(to: targetRect, animated: true)
    }
}

struct ZoomableImageView: UIViewRepresentable {
    var image: UIImage?

    func makeUIView(context _: Context) -> ZoomableMediaView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return ZoomableMediaView(mediaView: imageView)
    }

    func updateUIView(_ uiView: ZoomableMediaView, context _: Context) {
        (uiView.mediaView as? UIImageView)?.image = image
    }
}
