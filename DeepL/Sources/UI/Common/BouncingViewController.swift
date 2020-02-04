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

final class BouncingViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let scrollViewContentContainer = UIView()
    private let contentController: UIViewController

    init(contentController: UIViewController) {
        self.contentController = contentController

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundColor = Styles.Colors.background
        view.backgroundColor = backgroundColor
        scrollViewContentContainer.backgroundColor = backgroundColor

        scrollView.backgroundColor = backgroundColor
        scrollView.preservesSuperviewLayoutMargins = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        view.embedSubview(scrollView)

        scrollView.embedSubview(scrollViewContentContainer)
        scrollView.widthAnchor.constraint(equalTo: scrollViewContentContainer.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: scrollViewContentContainer.heightAnchor).isActive = true

        embedChild(contentController, in: scrollViewContentContainer)

        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = Styles.Colors.background
        view.addSubview(topView)

        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: topView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
        ])
    }
}
