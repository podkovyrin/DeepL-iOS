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

enum Styles {
    enum Colors {
        // Force unwrapping here works as a check whether color was defined
        static let background = UIColor(named: "BackgroundColor")!
        static let tint = UIColor(named: "TintColor")!
        static let label = UIColor(named: "LabelColor")!
        static let textView = UIColor(named: "TextViewColor")!
        static let error = UIColor(named: "ErrorColor")!
        static let placeholder = UIColor(named: "PlaceholderTextColor")!
        static let highlight = UIColor(named: "HighlightColor")!
    }

    enum Sizes {
        static let halfSpacing: CGFloat = 4
        static let spacing: CGFloat = 8
        static let doubleSpacing: CGFloat = 16
        static let minButtonHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 10
    }
}
