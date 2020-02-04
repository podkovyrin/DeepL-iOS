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

class GroupTranslationTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "GroupTranslationTests")!
    }

    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removePersistentDomain(forName: "GroupTranslationTests")
    }

    func testGroupTranslation() {
        // 1. Fail a root GroupTranslationOperation with 413
        // 2. Succeed two children of the root GroupTranslationOperation

        let sourceText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Mauris nunc congue nisi vitae suscipit tellus mauris a. Sed augue lacus viverra vitae congue eu consequat ac."

        let transport = TestTransport { request -> TaskResult in
            let response =
                """
                {
                    "translations": [
                        {"detected_source_language":"EN", "text":"Hallo, Welt"}
                    ]
                }
                """
            let data = response.data(using: .utf8)!

            let urlResponse = HTTPURLResponse(url: APIRouter.translate.url,
                                              statusCode: 413,
                                              httpVersion: nil,
                                              headerFields: nil)!
            let error = NetworkError.endpointError(urlResponse, nil)

            let params = request.params
            let text = params["text"]!

            if (text as NSString).length > Int(Double((sourceText as NSString).length) * 2.0 / 3.0) {
                return .failure(error)
            }
            else {
                return .success(data)
            }
        }

        let services = TestStubServices(userDefaults: userDefaults, transport: transport)

        // add detected_source_language to the storage
        let storage = services.languageStorage
        storage.updateLanguages([Language(code: "EN", name: "English")])

        let target = Language(code: "DE", name: "Deutsch")

        // Check if translation contains two operations with fetch result

        let expectation = XCTestExpectation(description: "Translate response")
        let operation = GroupTranslationOperation(text: sourceText, source: nil, target: target, services: services)
        operation.addCompletionObserver { operation, error in
            if case let .children(operations) = operation.result {
                XCTAssert(operations.count == 2)

                for childOp in operations {
                    if case let .fetch(translatedText) = childOp.result {
                        XCTAssertNotNil(translatedText.source)
                        XCTAssertEqual(translatedText.source!.code, "EN")
                        XCTAssertEqual(try! translatedText.translated.get(), "Hallo, Welt")
                    }
                    else {
                        XCTFail()
                    }
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

    func testFailedGroupTranslation() {
        let transport = TestTransport { request -> TaskResult in
            let urlResponse = HTTPURLResponse(url: APIRouter.translate.url,
                                              statusCode: 500,
                                              httpVersion: nil,
                                              headerFields: nil)!
            let error = NetworkError.endpointError(urlResponse, nil)

            return .failure(error)
        }

        let services = TestStubServices(userDefaults: userDefaults, transport: transport)

        let target = Language(code: "DE", name: "Deutsch")

        let expectation = XCTestExpectation(description: "Translate response")
        let operation = GroupTranslationOperation(text: "whatever", source: nil, target: target, services: services)
        operation.addCompletionObserver { operation, error in
            if case let .fetch(translatedText) = operation.result {
                if case let .failure(error) = translatedText.translated,
                    case let .endpointError(response, _) = error {
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

extension URLRequest {
    var params: [String: String] {
        let bodyString = String(data: httpBody!, encoding: .utf8)!
        let paramPairs = bodyString.split(separator: "&")
        var params = [String: String]()
        for pair in paramPairs {
            let keyValue = pair.split(separator: "=")
            let key = keyValue.first!.removingPercentEncoding!
            let value = keyValue.last!.removingPercentEncoding!
            params[key] = value
        }
        return params
    }
}
