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

protocol ErrorViewControllerDelegate: AnyObject {
    func retryAction()
}

final class ErrorViewController: UIViewController {
    weak var delegate: ErrorViewControllerDelegate?

    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private var activityIndicator: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        }
        else {
            style = .whiteLarge
        }
        return UIActivityIndicatorView(style: style)
    }()

    private lazy var stackView: UIStackView = {
        UIStackView(arrangedSubviews: [errorLabel, retryButton, activityIndicator])
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.backgroundColor = Styles.Colors.background
        errorLabel.textColor = Styles.Colors.label
        errorLabel.font = UIFont.font(forTextStyle: .body)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.titleLabel?.font = UIFont.font(forTextStyle: .headline)
        retryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonAction(_:)), for: .touchUpInside)

        activityIndicator.color = Styles.Colors.tint

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Styles.Sizes.doubleSpacing

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            retryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.Sizes.minButtonHeight),
        ])

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(contentSizeCategoryDidChangeNotification),
                                       name: UIContentSizeCategory.didChangeNotification,
                                       object: nil)
    }

    // MARK: Private

    @objc
    private func retryButtonAction(_ sender: UIButton) {
        delegate?.retryAction()
    }

    @objc
    private func contentSizeCategoryDidChangeNotification() {
        errorLabel.font = UIFont.font(forTextStyle: .body)
        retryButton.titleLabel?.font = UIFont.font(forTextStyle: .headline)
    }
}

extension ErrorViewController {
    var error: String? {
        get { errorLabel.text }
        set { errorLabel.text = newValue }
    }

    func showActivityIndicator() {
        activityIndicator.startAnimating()
        retryButton.isHidden = true
    }
}
