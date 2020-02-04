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

@testable import DeepL

import Foundation

class TestCancellationToken: CancellationToken {
    private(set) var cancelWasCalled = false

    func cancel() {
        cancelWasCalled = true
    }
}

class TestTransport: Transport {
    private var responseBlock: (URLRequest) -> TaskResult

    init(responseBlock: @escaping (URLRequest) -> TaskResult) {
        self.responseBlock = responseBlock
    }

    func dataTask(with request: URLRequest,
                  completion: @escaping (TaskResult) -> Void) -> TestCancellationToken {
        DispatchQueue.global(qos: .default).async {
            let result = self.responseBlock(request)
            completion(result)
        }

        return TestCancellationToken()
    }
}
