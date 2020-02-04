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

/// Adds inset from the bottom on devices without home indicator
class InsetViewController: UIViewController {
    let contentView = UIView()

    private var contentBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = Styles.Colors.background
        view.addSubview(contentView)

        let layoutGuide = view.layoutMarginsGuide
        let bottomConstraint = layoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([
            // don't inset from the top
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            bottomConstraint,
            layoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        contentBottomConstraint = bottomConstraint
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.window?.safeAreaInsets.bottom == 0 {
            contentBottomConstraint?.constant = view.layoutMargins.left
        }
        else {
            contentBottomConstraint?.constant = 0
        }
    }
}
