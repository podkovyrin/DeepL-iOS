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

typealias TranslationModel = TranslationResponse

final class FetchTranslationOperation: FetchOperation<TranslationModel> {
    // In
    let text: String
    let source: Language?
    let target: Language
    // Out
    private(set) var result: Result<TranslationResponse, NetworkError>?

    init(text: String, source: Language?, target: Language, apiClient: DeepLAPI, configuration: Configuration) {
        self.text = text
        self.source = source
        self.target = target

        super.init(apiClient: apiClient, configuration: configuration)
    }

    override func fetch(completion: @escaping (Result<TranslationModel, NetworkError>) -> Void) -> CancellationToken {
        apiClient.translate(text: text, source: source, target: target) { [weak self] result in
            guard let self = self else { return }

            self.result = result

            completion(result)
        }
    }
}
