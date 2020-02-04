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

private let retryAfterHeaderKey = "Retry-After"

enum NetworkError: Error {
    /// An `URLSession` error.
    case urlError(URLError)

    /// General `Error`.
    case generalError(Error)

    /// Neither `URLResponse` nor `URLError` are returned.
    case noResponse

    /// A `URLResponse` is not `HTTPURLResponse`.
    case invalidResponseType(URLResponse)

    /// Status code is in `200...299` range, but response body is empty.
    case noResponseData(HTTPURLResponse)

    /// Status code is `≥ 400`.
    case endpointError(HTTPURLResponse, Data?)
}

extension NetworkError {
    var canRetryImmediately: Bool {
        if case let .urlError(urlError) = self {
            switch urlError.code {
            case .timedOut,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .networkConnectionLost,
                 .dnsLookupFailed,
                 .httpTooManyRedirects,
                 .resourceUnavailable,
                 .notConnectedToInternet,
                 .secureConnectionFailed,
                 .cannotLoadFromNetwork:
                return true
            default:
                break
            }
        }
        else if case let .endpointError(response, _) = self {
            let code = response.statusCode
            if /* Request Timeout */ code == 408 ||
                /* Gateway Timeout */ code == 504 {
                return true
            }
        }

        return false
    }

    var canRetryHTTPError: Bool {
        if case let .endpointError(response, _) = self {
            let code = response.statusCode
            if /* Too Many Requests */ code == 429 ||
                /* Service Unavailable */ code == 503 {
                return true
            }

            if response.allHeaderFields[retryAfterHeaderKey] != nil {
                return true
            }
        }

        return false
    }

    var retryAfter: Date? {
        if case let .endpointError(response, _) = self,
            let retryAfter = response.allHeaderFields[retryAfterHeaderKey] {
            if let retryAfterSeconds = (retryAfter as? NSNumber)?.doubleValue {
                return Date(timeIntervalSinceNow: retryAfterSeconds)
            }

            if let retryAfterString = retryAfter as? String {
                if let retryAfterSeconds = Double(retryAfterString), retryAfterSeconds > 0 {
                    return Date(timeIntervalSinceNow: retryAfterSeconds)
                }

                return NetworkError.httpDateFormatter.date(from: retryAfterString)
            }
        }
        return nil
    }

    /// If this error can be resolved by retrying the request. Optimistic.
    var isRecoverableError: Bool {
        // [?] 400    Bad request. Please check error message and your parameters.
        // [x] 403    Authorization failed. Please supply a valid auth_key parameter.
        // [?] 404    The requested resource could not be found.
        // [x] 413    The request size exceeds the limit.
        // [v] 429    Too many requests. Please wait and resend your request.
        // [x] 456    Quota exceeded. The character limit has been reached.
        // [v] 503    Resource currently unavailable. Try again later.
        // [v] 5**    Internal error
        if case let .endpointError(response, _) = self {
            let code = response.statusCode
            if code == 403 ||
                code == 413 ||
                code == 456 {
                return false
            }
        }

        return true
    }

    private static var httpDateFormatter: DateFormatter = {
        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After#Examples
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}
