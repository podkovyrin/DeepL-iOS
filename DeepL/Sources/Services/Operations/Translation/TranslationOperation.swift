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

final class TranslationOperation: GroupOperation {
    // Out
    private(set) var translation: Translation?

    private let joinOperation: JoinTranslationsOperation

    init(text: String, source: Language?, target: Language, services: Services) {
        let truncated = String(text.prefix(services.configuration.maxSourceTextCharacters))
        let groupOperation = GroupTranslationOperation(text: truncated,
                                                       source: source,
                                                       target: target,
                                                       services: services)

        joinOperation = JoinTranslationsOperation(target: target,
                                                  source: source,
                                                  groupOperation: groupOperation,
                                                  languageStorage: services.languageStorage)
        joinOperation.addDependency(groupOperation)

        super.init(operations: [groupOperation, joinOperation])
    }

    override func operationDidFinish(_ operation: Operation, withErrors errors: [Error]) {
        if isCancelled || operation.isCancelled {
            return
        }

        if operation === joinOperation {
            translation = joinOperation.translation
        }
    }
}
