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

@testable import DeepL

import XCTest

// swiftlint:disable all

class TokenizerTests: XCTestCase {
    private let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Mauris nunc congue nisi vitae suscipit tellus mauris a. Sed augue lacus viverra vitae congue eu consequat ac. Vulputate enim nulla aliquet porttitor lacus luctus. Sed euismod nisi porta lorem mollis aliquam ut porttitor. Sit amet volutpat consequat mauris nunc congue. Lectus nulla at volutpat diam ut venenatis tellus in. Nam aliquam sem et tortor consequat id porta nibh venenatis. Cras adipiscing enim eu turpis egestas pretium aenean pharetra magna. Neque volutpat ac tincidunt vitae. Magna sit amet purus gravida quis blandit turpis. Cras semper auctor neque vitae tempus. Consectetur libero id faucibus nisl tincidunt eget. Ridiculus mus mauris vitae ultricies leo integer malesuada nunc vel. Mi proin sed libero enim sed faucibus turpis in. Semper feugiat nibh sed pulvinar proin gravida. Risus feugiat in ante metus dictum at tempor. Amet consectetur adipiscing elit duis tristique sollicitudin nibh. Tincidunt eget nullam non nisi est sit amet. Sed blandit libero volutpat sed. Rutrum tellus pellentesque eu tincidunt tortor aliquam nulla facilisi. Dignissim cras tincidunt lobortis feugiat vivamus at augue."

    func testTokenization() {
        for length in 13 ..< 2000 {
            tokenize(with: length)
        }
    }

    func testTokenizationPerformance() {
        measure {
            let tokenizer = Tokenizer(maxLength: 100)
            _ = tokenizer.tokenize(text)
        }
    }

    private func tokenize(with maxLength: Int) {
        let tokenizer = Tokenizer(maxLength: maxLength)
        let result = tokenizer.tokenize(text)

        result.forEach { range in
            let substring = (text as NSString).substring(with: range) as NSString
            XCTAssert(substring.length <= maxLength)
        }

        var textNew = ""
        for range in result {
            textNew += (text as NSString).substring(with: range)
        }

        XCTAssert(text == textNew)
    }
}
