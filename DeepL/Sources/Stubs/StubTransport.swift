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

import Foundation

class StubCancellationToken: CancellationToken {
    func cancel() {}
}

class StubTransport: Transport {
    private let responseByURL: [URL: () -> TaskResult]

    init() {
        var responseByURL = [URL: () -> TaskResult]()

        let languagesURL = APIRouter.languages.url
        let languagesResults: () -> TaskResult = {
            let languagesResponse =
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
            let languagesData = languagesResponse.data(using: .utf8)!

            let code = [403, 404, 500, 503].randomElement()!
            let response = HTTPURLResponse(url: languagesURL,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: ["Retry-After": "0.15"])!
            let error = NetworkError.endpointError(response, nil)

            return Bool.random() ? .success(languagesData) : .failure(error)
        }
        responseByURL[languagesURL] = languagesResults

        let translateURL = APIRouter.translate.url
        let translateResults: () -> TaskResult = {
            let results = [
                """
                {
                    "translations": [
                        {"detected_source_language":"EN", "text":"Hallo, Welt"}
                    ]
                }
                """,
                """
                {
                    "translations": [
                        {"detected_source_language":"RU", "text":"Der Tisch ist grün. Der Stuhl ist schwarz."}
                    ]
                }
                """,
                """
                {
                    "translations": [
                        {"detected_source_language":"FR", "text":"Das ist der erste Satz."},
                        {"detected_source_language":"FR", "text":"Das ist der zweite Satz."},
                        {"detected_source_language":"FR", "text":"Dies ist der dritte Satz."}
                    ]
                }
                """,
            ]

            let anyResult = results.randomElement()!
            let translationData = anyResult.data(using: .utf8)!

            let code = [429, 456, 503].randomElement()!
            let response = HTTPURLResponse(url: translateURL,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: ["Retry-After": "0.15"])!
            let error = NetworkError.endpointError(response, nil)

            return Bool.random() ? .success(translationData) : .failure(error)
        }
        responseByURL[translateURL] = translateResults

        self.responseByURL = responseByURL
    }

    func dataTask(with request: URLRequest,
                  completion: @escaping (TaskResult) -> Void) -> StubCancellationToken {
        let delay = Double.random(in: 0.2 ... 0.5)
        let deadline = DispatchTime.now() + delay
        DispatchQueue.global(qos: .default).asyncAfter(deadline: deadline) {
            let url = request.url!
            let result = self.responseByURL[url]!()
            completion(result)
        }

        return StubCancellationToken()
    }
}
