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

class TranslateAPITests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "TranslateTests")!
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "TranslateTests")
    }

    func testTranslation() {
        let transport = TestTransport { _ -> TaskResult in
            let response =
                """
                {
                    "translations": [
                        {"detected_source_language":"EN", "text":"Hallo, Welt"}
                    ]
                }
                """
            let data = response.data(using: .utf8)!
            return .success(data)
        }
        let services = TestStubServices(userDefaults: userDefaults, transport: transport)

        // add detected_source_language to the storage
        let storage = services.languageStorage
        storage.updateLanguages([Language(code: "EN", name: "English")])

        let target = Language(code: "DE", name: "Deutsch")

        let expectation = XCTestExpectation(description: "Translate response")
        let operation = TranslationOperation(text: "whatever", source: nil, target: target, services: services)
        operation.addCompletionObserver { operation, error in
            let translation = operation.translation!
            XCTAssertEqual(translation.source?.code, "EN")
            XCTAssertEqual(translation.target.code, target.code)

            XCTAssert(translation.data.count == 1)
            let text = translation.data.first!
            XCTAssertEqual(try! text.translated.get(), "Hallo, Welt")

            expectation.fulfill()
        }

        let operationQueue = ANOperationQueue()
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 60)
    }

    func testFailedTranslation() {
        let translateURL = APIRouter.translate.url
        let transport = TestTransport { _ -> TaskResult in
            let response = HTTPURLResponse(url: translateURL,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: ["Retry-After": "0.15"])!
            let error = NetworkError.endpointError(response, nil)

            return .failure(error)
        }
        let services = TestStubServices(userDefaults: userDefaults, transport: transport)

        let target = Language(code: "DE", name: "Deutsch")

        let expectation = XCTestExpectation(description: "Translate response")

        let operation = TranslationOperation(text: "whatever", source: nil, target: target, services: services)
        operation.addCompletionObserver { operation, error in
            let translation = operation.translation!

            XCTAssert(translation.data.count == 1)
            let text = translation.data.first!
            if case let .failure(error) = text.translated {
                if case let NetworkError.endpointError(response, nil) = error {
                    XCTAssertEqual(response.statusCode, 500)
                }
                else {
                    XCTFail()
                }
            }
            else {
                XCTFail()
            }

            expectation.fulfill()
        }

        let operationQueue = ANOperationQueue()
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 60)
    }
}
