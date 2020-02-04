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

enum GroupTranslationOperationResult {
    case fetch(TranslatedText)
    case children([GroupTranslationOperation])
}

final class GroupTranslationOperation: GroupOperation {
    // In
    let text: String
    let source: Language?
    let target: Language

    // Out
    private(set) var result: GroupTranslationOperationResult?

    private let services: Services

    init(text: String, source: Language?, target: Language, services: Services) {
        self.text = text
        self.source = source
        self.target = target
        self.services = services

        let fetchOperation = FetchTranslationOperation(text: text,
                                                       source: source,
                                                       target: target,
                                                       apiClient: services.apiClient,
                                                       configuration: services.configuration)

        super.init(operations: [fetchOperation])
    }

    override func operationDidFinish(_ operation: Operation, withErrors errors: [Error]) {
        if isCancelled || operation.isCancelled {
            return
        }

        // get result from the fetch operation, ignore completed children
        guard let operation = operation as? FetchTranslationOperation,
            let fetchResult = operation.result else {
            return
        }

        if case let .failure(error) = fetchResult,
            case let .endpointError(response, _) = error, response.statusCode == 413 {
            // The request size exceeds the limit.
            let errorPercent = services.configuration.splitterErrorPercent
            let splitter = TextTokenizationSplitter(text: text, errorPercent: errorPercent)
            let split = splitter.split()

            var childrenOperations = [GroupTranslationOperation]()
            for part in split {
                let childOp = GroupTranslationOperation(text: part,
                                                        source: source,
                                                        target: target,
                                                        services: services)
                childrenOperations.append(childOp)
            }

            result = .children(childrenOperations)

            childrenOperations.forEach { addOperation($0) }
        }
        else {
            let translated = fetchResult.map { $0.allText }
            let source = try? fetchResult.get().matchSource(from: services.languageStorage)
            let translatedText = TranslatedText(sourceText: text, source: source, translated: translated)
            result = .fetch(translatedText)
        }
    }
}

extension TranslationResponse {
    var allText: String {
        translations.map { $0.text }.joined(separator: "\n")
    }

    func matchSource(from storage: LanguageStorage) -> Language? {
        if let code = translations.first?.sourceLangCode {
            return storage.language(for: code)
        }
        return nil
    }
}
