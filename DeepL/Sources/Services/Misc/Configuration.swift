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

protocol Configuration {
    /// Text input debounce delay
    var textInputDelay: Double { get }

    /// Text input debounce delay when VoiceOver is on
    var textInputDelayVoiceOver: Double { get }

    /// Increase max text length by this error percent
    var splitterErrorPercent: Double { get }

    /// Number of retries to attempt on each network request
    var maxRetryCount: Int { get }

    /// Max number of characters to translate
    var maxSourceTextCharacters: Int { get }
}

struct ProductionConfiguration: Configuration {
    let textInputDelay = 0.5
    let textInputDelayVoiceOver = 2.0
    let splitterErrorPercent: Double = 0.1
    let maxRetryCount: Int = 3
    let maxSourceTextCharacters: Int = 5000
}
