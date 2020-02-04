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

final class KeyboardViewController: UIViewController {
    private let contentController: UIViewController
    private var bottomConstraint: NSLayoutConstraint?

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

        view.backgroundColor = Styles.Colors.background

        embedChild(contentController)
        bottomConstraint = contentController.view.findConstraint(layoutAttribute: .bottom)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unregisterFromKeyboardNotifications()
    }

    // MARK: Private

    private func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow(_:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide(_:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }

    private func unregisterFromKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func keyboardWillShow(_ n: Notification) {
        guard let userInfo = n.userInfo,
            let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIView.AnimationCurve(rawValue: curveValue) else {
            return
        }

        let convertedRect = view.convert(rect, from: nil)
        let height = convertedRect.height

        keyboardAnimation(height: height, duration: duration, curve: curve)
    }

    @objc
    private func keyboardWillHide(_ n: Notification) {
        guard let userInfo = n.userInfo,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIView.AnimationCurve(rawValue: curveValue) else {
            return
        }

        keyboardAnimation(height: 0, duration: duration, curve: curve)
    }

    private func keyboardAnimation(height: CGFloat, duration: TimeInterval, curve: UIView.AnimationCurve) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            let padding: CGFloat
            if height > 0 && self.view.window?.safeAreaInsets.bottom != 0 {
                padding = self.view.layoutMargins.left
            }
            else {
                padding = 0
            }
            self.bottomConstraint?.constant = padding + height
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
