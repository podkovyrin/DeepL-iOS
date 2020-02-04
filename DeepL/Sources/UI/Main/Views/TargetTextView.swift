//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Andrew Podkovyrin. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

final class TargetTextView: UIView {
    var text: String? {
        get {
            textView.text
        }
        set {
            textView.text = newValue
            stopAnimating()
        }
    }

    var attributedText: NSAttributedString? {
        get {
            textView.attributedText
        }
        set {
            textView.attributedText = newValue
            stopAnimating()
        }
    }

    weak var delegate: UITextViewDelegate? {
        get { textView.delegate }
        set { textView.delegate = newValue }
    }

    let toolbar: UIToolbar

    private let textView: UITextView
    private let shapeLayer: CAShapeLayer
    private let animationKey = "deepl.loading_animation"

    override init(frame: CGRect) {
        textView = UITextView(frame: .zero, textContainer: nil)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = Styles.Colors.textView
        textView.layer.cornerRadius = Styles.Sizes.cornerRadius
        textView.layer.masksToBounds = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = Styles.Colors.label
        let spacing = Styles.Sizes.spacing
        textView.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        textView.isEditable = false
        textView.linkTextAttributes = [
            .foregroundColor: Styles.Colors.error,
        ]
        let toolbarHeight = Styles.Sizes.minButtonHeight
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: toolbarHeight, right: 0)
        textView.accessibilityTraits = .staticText
        textView.accessibilityLabel = NSLocalizedString("Translated text", comment: "")

        // set UIToolbar frame explicitly to avoid warning on iOS 13
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: toolbarHeight))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Styles.Colors.tint.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [4, 2]
        shapeLayer.opacity = 0

        super.init(frame: frame)

        layer.cornerRadius = Styles.Sizes.cornerRadius
        layer.masksToBounds = true

        addSubview(textView)
        addSubview(toolbar)

        layer.addSublayer(shapeLayer)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            trailingAnchor.constraint(equalTo: textView.trailingAnchor),

            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
            trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        textView.textColor = Styles.Colors.label
        shapeLayer.strokeColor = Styles.Colors.tint.cgColor
    }

    func startAnimating() {
        shapeLayer.opacity = 1.0

        let dashPhaseDuration = 0.5
        let dashPhaseAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.lineDashPhase))
        dashPhaseAnimation.byValue = shapeLayer.lineDashPattern?.map { $0.floatValue }.reduce(0, +)
        dashPhaseAnimation.duration = dashPhaseDuration
        dashPhaseAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        dashPhaseAnimation.repeatCount = .infinity
        shapeLayer.add(dashPhaseAnimation, forKey: animationKey)
        shapeLayer.makeAnimationsPersistent()
    }

    func stopAnimating() {
        shapeLayer.opacity = 0
        shapeLayer.removeAnimation(forKey: animationKey)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if layer == self.layer {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            shapeLayer.path = path.cgPath
        }
    }
}
