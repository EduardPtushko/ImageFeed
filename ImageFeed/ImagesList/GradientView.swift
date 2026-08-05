//
//  GradientView.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 05.08.2026.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    @IBInspectable var startColor: UIColor? {
        didSet { updateColors() }
    }

    @IBInspectable var endColor: UIColor? {
        didSet { updateColors() }
    }

    @IBInspectable var bottomCornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = bottomCornerRadius
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            clipsToBounds = true
        }
    }

    private func updateColors() {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        let firstColor = startColor?.cgColor ?? UIColor.clear.cgColor
        let secondColor = endColor?.cgColor ?? UIColor.clear.cgColor
        gradientLayer.colors = [firstColor, secondColor]
    }

    func setColors(
        _ colors: [UIColor],
        start: CGPoint = CGPoint(x: 0.5, y: 0.0),
        end: CGPoint = CGPoint(x: 0.5, y: 1.0)
    ) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
    }
}
