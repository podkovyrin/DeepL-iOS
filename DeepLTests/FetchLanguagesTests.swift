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

import ANOperations
import XCTest

// swiftlint:disable all

class FetchLanguagesTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "FetchLanguagesTests")!
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "FetchLanguagesTests")
    }

    func testBasic() {
        let transport = TestTransport { _ -> TaskResult in
            let response =
                """
                [
                  { "language": "DE", "name": "Deutsch" },
                  { "language": "EN", "name": "English" },
                  { "language": "ES", "name": "Español" },
                  { "language": "FR", "name": "Français" },
                  { "language": "IT", "name": "Italiano" },
                  { "language": "NL", "name": "Nederlands" },
                  { "language": "PL", "name": "Polski" },
                  { "language": "PT", "name": "Português" },
                  { "language": "RU", "name": "русский язык" }
                ]
                """
            let data = response.data(using: .utf8)!
            return .success(data)
        }

        let services = TestStubServices(userDefaults: userDefaults, transport: transport)

        let expectation = XCTestExpectation(description: "Fetch Languages")

        let operation = FetchLanguagesOperation(services: services)
        operation.addCompletionObserver { operation, _ in
            XCTAssert(!services.languageStorage.languages.isEmpty)
            expectation.fulfill()
        }

        let operationQueue = ANOperationQueue()
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 60)
    }
}
