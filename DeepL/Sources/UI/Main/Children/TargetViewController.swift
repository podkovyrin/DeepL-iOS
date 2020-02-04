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

protocol TargetViewControllerDelegate: AnyObject {
    func shareTargetTextAction(text: String, sender: UIBarButtonItem)
}

final class TargetViewController: UIViewController {
    let languageSelectorButton = LanguageSelectorButton(type: .custom)
    let textView = TargetTextView()

    weak var delegate: TargetViewControllerDelegate?

    private let textViewBorderWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        languageSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        languageSelectorButton.title = NSLocalizedString("Translate into", comment: "")
        languageSelectorButton.shortTitle = NSLocalizedString("Into", comment: "")
        view.addSubview(languageSelectorButton)

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        let shareButton = UIBarButtonItem(barButtonSystemItem: .action,
                                          target: self,
                                          action: #selector(shareButtonAction(_:)))
        let copyButton = UIBarButtonItem(title: NSLocalizedString("Copy", comment: ""),
                                         style: .plain,
                                         target: self,
                                         action: #selector(copyButtonAction))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        textView.toolbar.setItems([spaceItem, copyButton, shareButton], animated: false)

        NSLayoutConstraint.activate([
            languageSelectorButton.topAnchor.constraint(equalTo: view.topAnchor),
            languageSelectorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: languageSelectorButton.trailingAnchor),
            languageSelectorButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.Sizes.minButtonHeight),

            textView.topAnchor.constraint(equalTo: languageSelectorButton.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // force text view to perform layoutSubviews, since it should be called on every bounds change
        textView.setNeedsLayout()
    }

    // MARK: Private

    @objc
    private func shareButtonAction(_ sender: UIBarButtonItem) {
        guard let text = textView.text else { return }
        delegate?.shareTargetTextAction(text: text, sender: sender)
    }

    @objc
    private func copyButtonAction() {
        UIPasteboard.general.string = textView.text
    }
}
