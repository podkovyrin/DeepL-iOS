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

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .generalError(error):
            return error.localizedDescription
        case let .urlError(urlError):
            return urlError.localizedDescription
        case .invalidResponseType, .noResponse:
            return NSLocalizedString("Internal error", comment: "")
        case .noResponseData:
            return nil
        case let .endpointError(response, _):
            let code = response.statusCode
            switch code {
            case 403, 404:
                return NSLocalizedString("Internal error", comment: "")
            case 413:
                return NSLocalizedString("The request size exceeds the limit.", comment: "")
            case 429:
                return NSLocalizedString("Too many requests. Please wait and resend your request.", comment: "")
            case 456:
                return NSLocalizedString("Quota exceeded. The character limit has been reached.", comment: "")
            default:
                let failed = NSLocalizedString("The request failed", comment: "")
                let localizedCode = HTTPURLResponse.localizedString(forStatusCode: code)
                return "\(failed): \(localizedCode) (\(code))"
            }
        }
    }
}
