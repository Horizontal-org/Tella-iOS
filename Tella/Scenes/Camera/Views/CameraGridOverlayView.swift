//
//  CameraGridOverlayView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import UIKit

final class CameraGridOverlayView: UIView {

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    private var gridLayer: CAShapeLayer {
        layer as! CAShapeLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        for fraction in [CGFloat(1) / 3, CGFloat(2) / 3] {
            let x = bounds.width * fraction
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))

            let y = bounds.height * fraction
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
        }
        gridLayer.path = path.cgPath
    }

    private func configure() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        gridLayer.fillColor = UIColor.clear.cgColor
        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        gridLayer.lineWidth = 1
    }
}
