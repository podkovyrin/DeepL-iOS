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

import ANOperations
import UIKit

final class AppCoordinator: Coordinating {
    let router: AppRouter
    let services: Services

    private let operationQueue: ANOperationQueue

    private var mainCoordinator: MainCoordinator?
    private var errorCoordinator: ErrorCoordinator?

    init(window: UIWindow) {
        window.backgroundColor = .black
        window.tintColor = Styles.Colors.tint
        window.makeKeyAndVisible()

        router = AppRouter(window: window)

        #warning("Running in Demo mode. Provide API auth key")
        let authKey = ""
        if authKey.isEmpty {
            services = StubServices()
        }
        else {
            services = ProductionServices(authKey: authKey)
        }

        operationQueue = ANOperationQueue()
        operationQueue.name = "com.deepl.queue"
    }

    func start() {
        fetchLanguages()

        startMainCoordinator()
    }

    // MARK: Private

    private func fetchLanguages() {
        let operation = FetchLanguagesOperation(services: services)
        operation.addCompletionObserver { [weak self] _, errors in
            guard let self = self else { return }

            if let error = errors.first {
                UIAccessibility.post(notification: .screenChanged,
                                     argument: NSLocalizedString("Error occured", comment: ""))

                self.startErrorCoordinator(error)
            }
            else {
                if self.mainCoordinator == nil {
                    UIAccessibility.post(notification: .screenChanged,
                                         argument: NSLocalizedString("Translator is ready", comment: ""))

                    self.startMainCoordinator()
                }
                else {
                    self.mainCoordinator?.updateLanguages()
                }
            }
        }
        operationQueue.addOperation(operation)
    }

    private func startErrorCoordinator(_ error: Error) {
        mainCoordinator = nil

        errorCoordinator = ErrorCoordinator(router: router,
                                            error: error.localizedDescription,
                                            retry: { [unowned self] in
                                                self.fetchLanguages()
        })
        errorCoordinator?.start()
    }

    private func startMainCoordinator() {
        errorCoordinator = nil

        mainCoordinator = MainCoordinator(router: router, services: services, operationQueue: operationQueue)
        mainCoordinator?.start()
    }
}
