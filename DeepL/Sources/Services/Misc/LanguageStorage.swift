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

protocol LanguageStorage {
    var languages: [Language] { get }

    func updateLanguages(_ languages: [Language])
    func language(for code: String) -> Language?
}

final class LanguageStorageImpl: LanguageStorage {
    private(set) var languages: [Language] {
        didSet {
            languageByCode = Dictionary(languages.lazy.map { ($0.code.lowercased(), $0) },
                                        uniquingKeysWith: { _, last in last })
        }
    }

    private var languageByCode = [String: Language]()
    private let userDefaults: UserDefaults
    private let languagesKey = "com.deepl.languages"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        languages = []

        // Defer reading of cached languages to make property observer fired
        defer {
            do {
                languages = try userDefaults.get(objectType: [Language].self, forKey: languagesKey) ?? []
            }
            catch {
                logVerbose(error)
            }
        }
    }

    func updateLanguages(_ languages: [Language]) {
        self.languages = languages

        do {
            try userDefaults.set(object: languages, forKey: languagesKey)
        }
        catch {
            logVerbose(error)
        }
    }

    func language(for code: String) -> Language? {
        languageByCode[code.lowercased()]
    }
}
