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

extension LanguageStorage {
    func sourcePlaceholderBuilder() -> NSAttributedString {
        let color = Styles.Colors.placeholder

        let title = NSLocalizedString("Type or paste text here.", comment: "")
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: UIFont.font(forTextStyle: .body),
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)

        var subtitleString: NSAttributedString?
        if !UIApplication.shared.isAccessibilityContentSize {
            let languageNames = languages.map { $0.name }
            if !languageNames.isEmpty {
                let joinedLanguages = languageNames.joined(separator: ", ")
                let subtitle = "(\(joinedLanguages))"
                let subtitleAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: color,
                    .font: UIFont.font(forTextStyle: .subheadline),
                ]
                subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
            }
        }

        let result = NSMutableAttributedString()
        result.beginEditing()
        result.append(titleString)
        if let subtitleString = subtitleString {
            result.append(NSAttributedString(string: "\n"))
            result.append(subtitleString)
        }
        result.endEditing()
        return result
    }
}

extension LanguageStorage {
    /// Current locale language or first language from the list which is not equal to except
    func preferredTargetLanguage(except exceptLanguage: Language?) -> Language? {
        for identifier in Locale.preferredLanguages {
            let localeComponents = Locale.components(fromIdentifier: identifier)
            if let code = localeComponents["kCFLocaleLanguageCodeKey"],
                let language = language(for: code),
                language != exceptLanguage {
                return language
            }
        }

        return languages.first(where: { $0 != exceptLanguage })
    }
}
