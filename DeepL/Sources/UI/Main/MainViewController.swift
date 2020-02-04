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

protocol MainViewControllerDelegate: SourceViewControllerDelegate, TargetViewControllerDelegate {
    func showSourceLanguageSelector(sender: UIButton)
    func showTargetLanguageSelector(sender: UIButton)
    func handle(url: URL) -> Bool
}

final class MainViewController: InsetViewController {
    weak var delegate: MainViewControllerDelegate? {
        didSet {
            sourceController.delegate = delegate
            targetController.delegate = delegate
        }
    }

    private let sourceContainerView = UIView()
    private let targetContainerView = UIView()
    private let sourceController = SourceViewController()
    private let targetController = TargetViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        sourceContainerView.translatesAutoresizingMaskIntoConstraints = false
        sourceContainerView.backgroundColor = Styles.Colors.background

        targetContainerView.translatesAutoresizingMaskIntoConstraints = false
        targetContainerView.backgroundColor = Styles.Colors.background

        // Source configuration

        sourceController.languageSelectorButton.addTarget(self,
                                                          action: #selector(sourceLanguageButtonAction(_:)),
                                                          for: .touchUpInside)

        // Target configuration

        targetController.textView.delegate = self
        targetController.languageSelectorButton.addTarget(self,
                                                          action: #selector(targetLanguageButtonAction(_:)),
                                                          for: .touchUpInside)

        // Embed

        contentView.addSubview(sourceContainerView)
        contentView.addSubview(targetContainerView)

        NSLayoutConstraint.activate([
            sourceContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sourceContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: sourceContainerView.trailingAnchor),

            targetContainerView.topAnchor.constraint(equalTo: sourceContainerView.bottomAnchor),
            targetContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: targetContainerView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: targetContainerView.trailingAnchor),

            sourceContainerView.heightAnchor.constraint(equalTo: targetContainerView.heightAnchor),
        ])

        embedChild(sourceController, in: sourceContainerView)
        embedChild(targetController, in: targetContainerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Workaround to show keyboard with proper animation.
        // Don't pass self by strong ref, because controller may be dismissed almost immediately
        DispatchQueue.main.async { [weak self] in
            self?.sourceController.textView.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _ = sourceController.textView.resignFirstResponder()
    }

    // MARK: Private

    @objc
    private func sourceLanguageButtonAction(_ sender: UIButton) {
        delegate?.showSourceLanguageSelector(sender: sender)
    }

    @objc
    private func targetLanguageButtonAction(_ sender: UIButton) {
        delegate?.showTargetLanguageSelector(sender: sender)
    }
}

extension MainViewController {
    var sourceLanguage: Language? {
        sourceController.languageSelectorButton.language
    }

    var targetLanguage: Language? {
        get { targetController.languageSelectorButton.language }
        set { targetController.languageSelectorButton.language = newValue }
    }

    var sourceText: String? {
        get { sourceController.textView.text }
        set { sourceController.textView.text = newValue }
    }

    var targetText: NSAttributedString? {
        get { targetController.textView.attributedText }
        set { targetController.textView.attributedText = newValue }
    }

    var sourcePlaceholderBuilder: (() -> NSAttributedString)? {
        get { sourceController.textView.placeholderBuilder }
        set { sourceController.textView.placeholderBuilder = newValue }
    }

    var maxSourceCharacters: Int {
        get { sourceController.maxCharacters }
        set { sourceController.maxCharacters = newValue }
    }

    func setSourceLanguage(_ language: Language?, detected: Bool) {
        sourceController.languageSelectorButton.setLanguage(language, detected: detected)
    }

    func startTargetTextViewAnimating() {
        targetController.textView.startAnimating()
    }
}

extension MainViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        let handled = delegate?.handle(url: URL) ?? false
        return !handled
    }
}
