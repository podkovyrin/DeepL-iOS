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

protocol SourceViewControllerDelegate: AnyObject {
    func sourceTextDidChange(text: String?)
}

final class SourceViewController: UIViewController {
    weak var delegate: SourceViewControllerDelegate?

    var maxCharacters: Int = 0 {
        didSet {
            updateTextCounter()
        }
    }

    let languageSelectorButton = LanguageSelectorButton(type: .custom)
    let textView = PlaceholderTextView(frame: .zero, textContainer: nil)

    private let countLabel = UILabel()
    private let countLabelBackgroundView = UIView()
    private let clearButton = UIButton(type: .system)
    private let textViewBorderWidth: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        languageSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        languageSelectorButton.title = NSLocalizedString("Translate from", comment: "")
        languageSelectorButton.shortTitle = NSLocalizedString("From", comment: "")
        view.addSubview(languageSelectorButton)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = Styles.Colors.textView
        textView.layer.cornerRadius = Styles.Sizes.cornerRadius
        textView.layer.masksToBounds = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = Styles.Colors.label
        textView.delegate = self
        let spacing = Styles.Sizes.spacing
        textView.textContainerInset = UIEdgeInsets(top: spacing,
                                                   left: spacing,
                                                   bottom: spacing,
                                                   right: Styles.Sizes.minButtonHeight)
        textView.accessibilityLabel = NSLocalizedString("Text to translate", comment: "")
        view.addSubview(textView)

        countLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        countLabelBackgroundView.backgroundColor = Styles.Colors.textView
        view.addSubview(countLabelBackgroundView)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.backgroundColor = Styles.Colors.textView
        countLabel.textColor = Styles.Colors.label
        countLabel.font = UIFont.font(forTextStyle: .caption1)
        countLabel.accessibilityLabel = NSLocalizedString("Characters count", comment: "")
        view.addSubview(countLabel)

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "clear_icon")!
        clearButton.setImage(image, for: .normal)
        clearButton.tintColor = Styles.Colors.placeholder
        clearButton.accessibilityLabel = NSLocalizedString("Clear text", comment: "")
        clearButton.isHidden = true
        clearButton.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        view.addSubview(clearButton)

        NSLayoutConstraint.activate([
            languageSelectorButton.topAnchor.constraint(equalTo: view.topAnchor),
            languageSelectorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: languageSelectorButton.trailingAnchor),
            languageSelectorButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.Sizes.minButtonHeight),

            textView.topAnchor.constraint(equalTo: languageSelectorButton.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),

            countLabel.topAnchor.constraint(equalTo: countLabelBackgroundView.topAnchor,
                                            constant: Styles.Sizes.halfSpacing),
            countLabel.leadingAnchor.constraint(equalTo: countLabelBackgroundView.leadingAnchor,
                                                constant: Styles.Sizes.halfSpacing),
            textView.bottomAnchor.constraint(equalTo: countLabelBackgroundView.bottomAnchor,
                                             constant: textViewBorderWidth),
            countLabelBackgroundView.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor,
                                                               constant: Styles.Sizes.halfSpacing),

            textView.bottomAnchor.constraint(equalTo: countLabel.bottomAnchor,
                                             constant: Styles.Sizes.halfSpacing),
            textView.trailingAnchor.constraint(equalTo: countLabel.trailingAnchor,
                                               constant: Styles.Sizes.doubleSpacing),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textView.leadingAnchor,
                                                constant: Styles.Sizes.doubleSpacing),

            clearButton.topAnchor.constraint(equalTo: textView.topAnchor),
            textView.trailingAnchor.constraint(equalTo: clearButton.trailingAnchor),
            clearButton.heightAnchor.constraint(equalToConstant: Styles.Sizes.minButtonHeight),
            clearButton.widthAnchor.constraint(equalToConstant: Styles.Sizes.minButtonHeight),
        ])

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(contentSizeCategoryDidChangeNotification),
                                       name: UIContentSizeCategory.didChangeNotification,
                                       object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bottom = countLabel.bounds.height + Styles.Sizes.spacing
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        textView.layer.borderColor = Styles.Colors.tint.cgColor
    }

    // MARK: Private

    private func updateTextCounter() {
        let count = textView.text.count
        countLabel.text = "\(count) / \(maxCharacters)"
        let format = NSLocalizedString("%ld of %ld", comment: "10 of 1000 (characters)")
        countLabel.accessibilityValue = String(format: format, count, maxCharacters)
    }

    @objc
    private func contentSizeCategoryDidChangeNotification() {
        countLabel.font = UIFont.font(forTextStyle: .caption1)
    }

    @objc
    private func clearButtonAction() {
        textView.text = nil
        textViewDidChange(textView)
    }
}

extension SourceViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextCounter()
        clearButton.isHidden = textView.text.isEmpty
        delegate?.sourceTextDidChange(text: textView.text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = Styles.Colors.tint.cgColor
        textView.layer.borderWidth = textViewBorderWidth
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
    }
}
