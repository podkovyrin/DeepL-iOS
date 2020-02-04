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

enum NetworkErrorClassificationURL {
    static let retriable = "deepl_internal://retriable"
    static let unrecoverable = "deepl_internal://unrecoverable"
}

extension Translation {
    /// Join Translation data into single attributed string
    var attributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.beginEditing()

        var iter = data.makeIterator()
        if let first = iter.next() {
            attributedText.append(first.attributedText(target: target))
            var isPreviousFailed = first.isFailed
            while let next = iter.next() {
                let isCurrentFailed = next.isFailed
                let separator = isPreviousFailed || isCurrentFailed ? "\n" : " "
                attributedText.append(NSAttributedString(string: separator))
                attributedText.append(next.attributedText(target: target))

                isPreviousFailed = isCurrentFailed
            }
        }

        attributedText.endEditing()
        return attributedText
    }
}

extension TranslatedText {
    /// Convert TranslatedText into attributed string
    func attributedText(target: Language) -> NSAttributedString {
        let font = UIFont.font(forTextStyle: .body)

        switch translated {
        case let .success(text):
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
            ]
            let result = NSAttributedString(string: text, attributes: attributes)
            result.accessibilityLanguage = target.code.lowercased()
            return result
        case let .failure(error):
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            if error.isRecoverableError {
                let tapToRetry = NSLocalizedString("Tap to Retry", comment: "")
                let string = "\(error.localizedDescription)\n\(tapToRetry)"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .paragraphStyle: paragraphStyle,
                    .link: NetworkErrorClassificationURL.retriable,
                    .underlineStyle: NSUnderlineStyle.single.union(.patternDot).rawValue,
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
            else {
                let string = error.localizedDescription
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .paragraphStyle: paragraphStyle,
                    .link: NetworkErrorClassificationURL.unrecoverable,
                ]
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
    }
}
