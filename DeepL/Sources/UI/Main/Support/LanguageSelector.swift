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

import UIKit

protocol LanguageSelectionTarget: AnyObject {
    var sourceLanguage: Language? { get }
    var targetLanguage: Language? { get set }

    func setSourceLanguage(_ language: Language?, detected: Bool)
}

enum LanguageSelectionResult {
    case notChanged
    case updated
}

final class LanguageSelector {
    let anyLanguage: Language

    private let router: AppRouter
    private let userDefaults: UserDefaults
    private let storage: LanguageStorage
    private let target: LanguageSelectionTarget

    private var previousSourceLanguage: Language?

    init(router: AppRouter,
         userDefaults: UserDefaults,
         storage: LanguageStorage,
         target: LanguageSelectionTarget) {
        self.router = router
        self.userDefaults = userDefaults
        self.storage = storage
        self.target = target
        anyLanguage = Language(code: "?", name: "Any language")
    }

    func resetLanguages() {
        if target.sourceLanguage == nil {
            if let code = userDefaults.lastSourceLanguageCode, let language = storage.language(for: code) {
                target.setSourceLanguage(language, detected: false)
            }
            else {
                target.setSourceLanguage(anyLanguage, detected: false)
            }
        }

        if target.targetLanguage == nil {
            if let code = userDefaults.lastTargetLanguageCode, let language = storage.language(for: code) {
                target.targetLanguage = language
            }
            else {
                let source = target.sourceLanguage
                target.targetLanguage = storage.preferredTargetLanguage(except: source)
            }
        }
    }

    func showSourceLanguageSelector(sender: UIButton,
                                    completion: @escaping (LanguageSelectionResult) -> Void) {
        let languages = [anyLanguage] + storage.languages
        showLanguageSelector(sender: sender, languages: languages) { language in
            guard let language = language else {
                completion(.notChanged)
                return
            }

            guard self.target.sourceLanguage != language else {
                // reset source language to be user-selected (if `detected` was set before)
                self.target.setSourceLanguage(language, detected: false)
                completion(.notChanged)
                return
            }

            self.setSourceLanguage(language)
            completion(.updated)
        }
    }

    func showTargetLanguageSelector(sender: UIButton,
                                    completion: @escaping (LanguageSelectionResult) -> Void) {
        var languages = storage.languages
        if let source = target.sourceLanguage, let index = languages.firstIndex(of: source) {
            languages.remove(at: index)
        }
        showLanguageSelector(sender: sender, languages: languages) { language in
            guard let language = language, self.target.targetLanguage != language else {
                completion(.notChanged)
                return
            }

            self.setTargetLanguage(language)
            completion(.updated)
        }
    }

    // MARK: Private

    private func showLanguageSelector(sender: UIButton,
                                      languages: [Language],
                                      completion: @escaping (Language?) -> Void) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for language in languages {
            let action = UIAlertAction(title: language.name, style: .default) { _ in
                completion(language)
            }
            actionSheet.addAction(action)
        }

        let action = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completion(nil)
        }
        actionSheet.addAction(action)

        if UIDevice.current.userInterfaceIdiom == .pad {
            let presentationController = actionSheet.popoverPresentationController
            presentationController?.sourceView = sender
            presentationController?.sourceRect = sender.bounds
        }

        router.showViewController(actionSheet)
    }

    private func setSourceLanguage(_ language: Language) {
        if language == anyLanguage {
            previousSourceLanguage = target.sourceLanguage
        }

        if target.targetLanguage == language {
            let targetLanguage: Language?
            if target.sourceLanguage != anyLanguage {
                targetLanguage = target.sourceLanguage
            }
            else {
                if let previousSourceLanguage = previousSourceLanguage, previousSourceLanguage != language {
                    targetLanguage = previousSourceLanguage
                }
                else {
                    targetLanguage = storage.preferredTargetLanguage(except: language)
                }
            }
            setTargetLanguage(targetLanguage)
        }

        target.setSourceLanguage(language, detected: false)
        userDefaults.lastSourceLanguageCode = language != anyLanguage ? language.code : nil
    }

    private func setTargetLanguage(_ language: Language?) {
        target.targetLanguage = language
        userDefaults.lastTargetLanguageCode = language?.code
    }
}
