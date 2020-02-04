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

final class LanguageSelectorButton: UIButton {
    var title: String? {
        didSet {
            resetAttributedTitle()
        }
    }

    var shortTitle: String? {
        didSet {
            resetAttributedTitle()
        }
    }

    var language: Language? {
        didSet {
            resetAttributedTitle()
        }
    }

    private var detected = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    func setLanguage(_ language: Language?, detected: Bool) {
        self.detected = detected
        self.language = language // will trigger resetAttributedTitle
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        resetAttributedTitle()
    }

    // `intrinsicContentSize` and `layoutSubviews` fixes wrong height of a multiline button

    override var intrinsicContentSize: CGSize {
        guard let titleLabel = titleLabel else {
            preconditionFailure("Internal inconsistency")
        }

        let fittingSize = CGSize(width: titleLabel.preferredMaxLayoutWidth, height: .greatestFiniteMagnitude)
        var size = titleLabel.sizeThatFits(fittingSize)
        size.height += contentEdgeInsets.top + contentEdgeInsets.bottom
        return size
    }

    override func layoutSubviews() {
        titleLabel?.preferredMaxLayoutWidth = bounds.size.width

        super.layoutSubviews()
    }

    // MARK: Private

    private func setup() {
        contentHorizontalAlignment = .leading

        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.adjustsFontSizeToFitWidth = true

        let spacing = Styles.Sizes.spacing
        contentEdgeInsets = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(resetAttributedTitle),
                                       name: UIContentSizeCategory.didChangeNotification,
                                       object: nil)
    }

    @objc
    private func resetAttributedTitle() {
        updateAttributedTitle(for: .normal)
        updateAttributedTitle(for: .highlighted)
        updateAttributedTitle(for: .selected)
    }

    private func updateAttributedTitle(for state: UIControl.State) {
        guard let title = title, let shortTitle = shortTitle else { return }

        let isAccessibilityContentSize = UIApplication.shared.isAccessibilityContentSize
        let currentTitle = isAccessibilityContentSize ? shortTitle : title
        let plainTitle: String
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
            plainTitle = " " + currentTitle
        }
        else {
            plainTitle = currentTitle + " "
        }

        let plainLanguage = language?.name ?? "…"

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Styles.Colors.label,
            .font: UIFont.font(forTextStyle: .subheadline),
        ]
        let titleString = NSAttributedString(string: plainTitle, attributes: titleAttributes)

        let color: UIColor
        if state == .highlighted || state == .selected {
            color = Styles.Colors.highlight
        }
        else {
            color = Styles.Colors.tint
        }

        let languageAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: UIFont.font(forTextStyle: .headline),
        ]
        let languageString = NSAttributedString(string: plainLanguage, attributes: languageAttributes)

        var detectedString: NSAttributedString?
        if detected && !isAccessibilityContentSize {
            let plainDetectedString = NSLocalizedString("(detected)", comment: "")
            detectedString = NSAttributedString(string: " \(plainDetectedString)", attributes: titleAttributes)
        }

        let result = NSMutableAttributedString()
        result.beginEditing()
        result.append(titleString)
        result.append(languageString)
        if let detectedString = detectedString {
            result.append(detectedString)
        }
        result.endEditing()

        setAttributedTitle(result, for: state)
    }
}
