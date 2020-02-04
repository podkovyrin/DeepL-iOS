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

final class PlaceholderTextView: UITextView {
    var placeholderBuilder: (() -> NSAttributedString)? {
        didSet {
            setNeedsUpdatePlaceholder()
        }
    }

    override var text: String! {
        didSet {
            setNeedsUpdatePlaceholder()
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            setNeedsUpdatePlaceholder()
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            setNeedsUpdatePlaceholder()
        }
    }

    private let placeholderTextView: UITextView

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        placeholderTextView = UITextView(frame: frame, textContainer: textContainer)

        super.init(frame: frame, textContainer: textContainer)

        setup()
    }

    required init?(coder: NSCoder) {
        placeholderTextView = UITextView()

        super.init(coder: coder)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        placeholderTextView.frame = bounds
    }

    override func insertText(_ text: String) {
        super.insertText(text)

        setNeedsUpdatePlaceholder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setNeedsUpdatePlaceholder()
    }

    // MARK: Private

    private func setup() {
        placeholderTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.isEditable = false
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.accessibilityElementsHidden = true
        insertSubview(placeholderTextView, at: 0)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(setNeedsUpdatePlaceholder),
                                       name: UITextView.textDidChangeNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(setNeedsUpdatePlaceholder),
                                       name: UIContentSizeCategory.didChangeNotification,
                                       object: nil)
    }

    @objc
    private func setNeedsUpdatePlaceholder() {
        let shouldShowPlacehoder = text == nil || text.isEmpty
        placeholderTextView.isHidden = !shouldShowPlacehoder

        guard let placeholderBuilder = placeholderBuilder, shouldShowPlacehoder else {
            return
        }

        placeholderTextView.textContainer.exclusionPaths = textContainer.exclusionPaths
        placeholderTextView.textContainerInset = textContainerInset
        placeholderTextView.textContainer.lineBreakMode = textContainer.lineBreakMode
        placeholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        placeholderTextView.textContainer.widthTracksTextView = textContainer.widthTracksTextView
        placeholderTextView.textContainer.heightTracksTextView = textContainer.heightTracksTextView

        let attributedPlaceholder = placeholderBuilder()
        placeholderTextView.attributedText = attributedPlaceholder
    }
}
