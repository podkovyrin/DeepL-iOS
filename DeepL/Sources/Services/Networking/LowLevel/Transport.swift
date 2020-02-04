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

protocol CancellationToken {
    func cancel()
}

typealias TaskResult = Result<Data, NetworkError>

protocol Transport {
    associatedtype Token: CancellationToken
    func dataTask(with request: URLRequest, completion: @escaping (TaskResult) -> Void) -> Token
}

extension URLSessionDataTask: CancellationToken {}

extension URLSession: Transport {
    func dataTask(with request: URLRequest, completion: @escaping (TaskResult) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request) { [unowned self] data, response, error in
            let result = self.process(data: data, response: response, error: error)
            completion(result)
        }
        task.resume()
        return task
    }

    // MARK: Private

    private func process(data: Data?, response: URLResponse?, error: Error?) -> TaskResult {
        if let urlError = error as? URLError {
            return .failure(.urlError(urlError))
        }
        else if let generalError = error {
            return .failure(.generalError(generalError))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            if let urlResponse = response {
                return .failure(.invalidResponseType(urlResponse))
            }
            else {
                return .failure(.noResponse)
            }
        }

        if httpResponse.statusCode >= 400 {
            return .failure(.endpointError(httpResponse, data))
        }

        guard let data = data, !data.isEmpty else {
            return .failure(.noResponseData(httpResponse))
        }

        return .success(data)
    }
}
