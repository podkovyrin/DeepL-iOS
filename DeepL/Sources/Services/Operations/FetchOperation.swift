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
import Foundation

/// Abstract Networking NSOperation
class FetchOperation<Model>: ANOperation {
    let apiClient: DeepLAPI
    private var cancellationToken: CancellationToken?
    private let maxRetriesCount: Int
    private var retryCount = 0
    private let exponentialTimer: ExponentialTimer

    init(apiClient: DeepLAPI, configuration: Configuration) {
        self.apiClient = apiClient
        maxRetriesCount = configuration.maxRetryCount
        exponentialTimer = ExponentialTimer(initialTime: 1, maxTime: 60)

        super.init()
    }

    func fetch(completion: @escaping (Result<Model, NetworkError>) -> Void) -> CancellationToken {
        preconditionFailure("This method must be overriden")
    }

    final override func execute() {
        retryCount += 1

        cancellationToken = fetch { [weak self] result in
            guard let self = self else { return }

            if self.isCancelled {
                return
            }

            switch result {
            case let .failure(error):
                let haveAttempts = self.retryCount <= self.maxRetriesCount
                if error.canRetryImmediately && haveAttempts {
                    self.execute()
                }
                if error.canRetryHTTPError && haveAttempts {
                    let timeInterval: TimeInterval
                    let currentTime = CFAbsoluteTimeGetCurrent()
                    if let retryAbsoluteTime = error.retryAfter?.timeIntervalSinceReferenceDate,
                        currentTime < retryAbsoluteTime {
                        timeInterval = retryAbsoluteTime - currentTime
                    }
                    else {
                        timeInterval = self.exponentialTimer.timeIntervalAndCalculateNext()
                    }

                    let queue = DispatchQueue.global(qos: .default)
                    let deadline = DispatchTime.now() + timeInterval
                    queue.asyncAfter(deadline: deadline, execute: self.execute)
                }
                else {
                    self.finishWithError(error)
                }
            case .success:
                self.finish()
            }
        }
    }

    override func cancel() {
        cancellationToken?.cancel()

        super.cancel()
    }
}
