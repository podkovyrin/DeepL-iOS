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

final class ContainerViewController: UIViewController {
    var content: UIViewController? {
        didSet {
            replaceChild(oldValue, with: content)
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    init(content: UIViewController?) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(content: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Styles.Colors.background

        replaceChild(nil, with: content)
    }

    override var childForStatusBarStyle: UIViewController? {
        content
    }

    // MARK: Private

    private func replaceChild(_ oldChild: UIViewController?, with newChild: UIViewController?) {
        let duration: TimeInterval
        let options: UIView.AnimationOptions
        if viewIfLoaded?.window == nil {
            duration = 0
            options = []
        }
        else {
            duration = 0.3
            options = .transitionCrossDissolve
        }

        switch (oldChild, newChild) {
        case let (old?, new?):
            transition(from: old, to: new, in: view, duration: duration, options: options)
        case (nil, let new?):
            transition(to: new, in: view, duration: duration, options: options)
        case (let old?, nil):
            transition(from: old, in: view, duration: duration, options: options)
        case (nil, nil):
            return
        }
    }

    private func transition(to: UIViewController,
                            in container: UIView,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions) {
        // embed the "to" view
        // animate it in

        addChild(to)
        to.view.alpha = 0
        container.embedSubview(to.view)

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            to.view.alpha = 1
        }, completion: { _ in
            to.didMove(toParent: self)
        })
    }

    private func transition(from: UIViewController,
                            in container: UIView,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions) {
        // animate out the "from" view
        // remove it

        from.willMove(toParent: nil)
        UIView.animate(withDuration: duration, animations: {
            from.view.alpha = 0
        }, completion: { _ in
            from.view.removeFromSuperview()
            from.removeFromParent()
        })
    }

    private func transition(from: UIViewController,
                            to: UIViewController,
                            in container: UIView,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions) {
        if from == to { return }

        // animate from "from" view to "to" view

        from.willMove(toParent: nil)
        addChild(to)

        to.view.alpha = 0
        from.view.alpha = 1

        container.embedSubview(to.view)
        container.bringSubviewToFront(from.view)

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            to.view.alpha = 1
            from.view.alpha = 0
        }, completion: { _ in
            from.view.removeFromSuperview()

            from.removeFromParent()
            to.didMove(toParent: self)
        })
    }
}
