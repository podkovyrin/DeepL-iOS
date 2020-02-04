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

typealias LanguagesModel = [Language]

final class FetchLanguagesOperation: FetchOperation<LanguagesModel> {
    private var languageStorage: LanguageStorage

    init(services: Services) {
        languageStorage = services.languageStorage

        super.init(apiClient: services.apiClient, configuration: services.configuration)
    }

    override func fetch(completion: @escaping (Result<LanguagesModel, NetworkError>) -> Void) -> CancellationToken {
        apiClient.fetchLanguages { [weak self] result in
            guard let self = self else { return }

            if let languages = try? result.get() {
                self.languageStorage.updateLanguages(languages)
            }

            completion(result)
        }
    }
}
