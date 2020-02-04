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

protocol Request {
    var url: URL { get }
    var method: String { get }
    var parameters: [String: Any] { get }
}

extension Request {
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}

struct PostRequest: Request, URLRequestConvertible {
    let url: URL
    var parameters: [String: Any]
    var method: String {
        "POST"
    }

    init(url: URL, parameters: [String: Any] = [:]) {
        self.url = url
        self.parameters = parameters
    }
}
