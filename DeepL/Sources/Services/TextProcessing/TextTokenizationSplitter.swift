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

// For safety reasons and because some characters might be escaped by the encoder,
// we calculate the size of the string and adding additional 10% of the "data cost".

final class TextTokenizationSplitter {
    private let text: String
    private let maxLength: Int
    private let tokenizer: Tokenizer

    /// Splits `text` into `text.length / 2` chunks
    convenience init(text: String, errorPercent: Double) {
        let maxTextLength = (text as NSString).length / 2
        self.init(text: text, maxTextLength: maxTextLength, errorPercent: errorPercent)
    }

    init(text: String, maxTextLength: Int, errorPercent: Double) {
        assert(errorPercent >= -1 && errorPercent < 1)

        self.text = text
        maxLength = maxTextLength + Int(errorPercent * Double(maxTextLength))
        tokenizer = Tokenizer(maxLength: maxLength)
    }

    func split() -> [String] {
        let textLength = (text as NSString).length
        if textLength > maxLength {
            let ranges = tokenizer.tokenize(text)
            let nsText = text as NSString
            var result = [String]()
            for range in ranges {
                let substring = nsText.substring(with: range)
                result.append(substring)
            }
            return result
        }
        else {
            return [text]
        }
    }
}
