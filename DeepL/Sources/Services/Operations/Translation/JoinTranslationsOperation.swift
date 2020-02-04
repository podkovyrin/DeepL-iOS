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

final class JoinTranslationsOperation: ANOperation {
    // In
    let target: Language
    let source: Language?
    let groupOperation: GroupTranslationOperation
    // Out
    private(set) var translation: Translation?

    private let languageStorage: LanguageStorage

    init(target: Language,
         source: Language?,
         groupOperation: GroupTranslationOperation,
         languageStorage: LanguageStorage) {
        self.target = target
        self.source = source
        self.groupOperation = groupOperation
        self.languageStorage = languageStorage

        super.init()
    }

    override func execute() {
        if isCancelled || groupOperation.isCancelled {
            return
        }

        let data = joinGroupResults(operation: groupOperation)
        translation = Translation(target: target, data: data)

        finish()
    }
}

// MARK: Private

private func joinGroupResults(operation: GroupTranslationOperation) -> [TranslatedText] {
    var results = [TranslatedText]()
    switch operation.result {
    case let .fetch(result):
        results.append(result)
    case let .children(children):
        for child in children {
            let childResults = joinGroupResults(operation: child)
            results.append(contentsOf: childResults)
        }
    case .none:
        preconditionFailure("Operation is invalid: \(operation)")
    }
    return results
}
