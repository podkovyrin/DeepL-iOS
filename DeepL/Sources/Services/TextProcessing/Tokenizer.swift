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

// TODO: consider using NaturalLanguage framework on iOS 12+

final class Tokenizer {
    private let maxLength: Int

    init(maxLength: Int) {
        self.maxLength = maxLength
    }

    func tokenize(_ text: String) -> [NSRange] {
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text

        let nsText = text as NSString
        let textRange = NSRange(location: 0, length: nsText.length)
        return tokenizeText(nsText, in: textRange, tagger: tagger)
    }

    // MARK: Private

    private func tokenizeText(_ text: NSString, in textRange: NSRange, tagger: NSLinguisticTagger) -> [NSRange] {
        var result = [NSRange]()

        var location = textRange.location
        tagger.enumerateTags(in: textRange, unit: .sentence, scheme: .tokenType, options: []) { _, range, _ in
            let position = range.location + range.length
            let previousAndCurrentRange = NSRange(location: location, length: position - location)
            let previousAndCurrentSize = size(of: text, at: previousAndCurrentRange)
            if previousAndCurrentSize >= maxLength {
                if previousAndCurrentSize == maxLength {
                    result.append(previousAndCurrentRange)
                    location = position
                }
                else if range.location != location {
                    let prevRange = NSRange(location: location, length: range.location - location)
                    result.append(prevRange)
                    location = range.location
                }

                let rangeSize = size(of: text, at: range)

                if rangeSize > maxLength {
                    let splittedRange = tokenizeSentence(in: range, text: text, tagger: tagger)
                    result.append(contentsOf: splittedRange)
                    location = position
                }
                else if rangeSize == maxLength && location != position {
                    result.append(range)
                    location = position
                }
            }
        }

        let position = textRange.location + textRange.length
        if location < position {
            let range = NSRange(location: location, length: position - location)
            result.append(range)
        }

        return result
    }

    // MARK: Private

    /// Splits a sentence into an array of multiple words where every element *ideally* not exceeds `maxLength`.
    /// If specified `maxLength` is too small to fit a single "word" it won't be split into characters.
    private func tokenizeSentence(in sentenceRange: NSRange,
                                  text: NSString,
                                  tagger: NSLinguisticTagger) -> [NSRange] {
        var result = [NSRange]()

        var location = sentenceRange.location

        tagger.enumerateTags(in: sentenceRange,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.joinNames]) { _, range, _ in
            assert(size(of: text, at: range) <= maxLength, "maxLength (==\(maxLength)) is too small")

            let position = range.location + range.length
            let previousAndCurrentRange = NSRange(location: location, length: position - location)
            let previousAndCurrentSize = size(of: text, at: previousAndCurrentRange)
            if previousAndCurrentSize >= maxLength {
                if previousAndCurrentSize == maxLength {
                    result.append(previousAndCurrentRange)
                    location = position
                }
                else if range.location != location {
                    let prevRange = NSRange(location: location, length: range.location - location)
                    result.append(prevRange)
                    location = range.location
                }

                if size(of: text, at: range) == maxLength && location != position {
                    result.append(range)
                    location = position
                }
            }
        }

        let position = sentenceRange.location + sentenceRange.length
        if location < position {
            let range = NSRange(location: location, length: position - location)
            result.append(range)
        }

        return result
    }

    private func size(of text: NSString, at range: NSRange) -> Int {
        let substring = text.substring(with: range) as NSString
        return substring.length
    }
}
