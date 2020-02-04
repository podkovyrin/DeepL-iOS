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

final class ErrorCoordinator: Coordinating {
    var primaryViewController: UIViewController { bouncingController }

    private let router: AppRouter

    private let error: String
    private let retry: () -> Void

    private let errorController: ErrorViewController
    private let bouncingController: BouncingViewController

    init(router: AppRouter, error: String, retry: @escaping () -> Void) {
        self.router = router
        self.error = error
        self.retry = retry

        errorController = ErrorViewController()
        errorController.error = error

        bouncingController = BouncingViewController(contentController: errorController)

        errorController.delegate = self
    }

    func start() {
        router.showViewController(primaryViewController)
    }
}

extension ErrorCoordinator: ErrorViewControllerDelegate {
    func retryAction() {
        errorController.showActivityIndicator()
        retry()
    }
}
