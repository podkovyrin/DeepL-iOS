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

final class Session<T: Transport> {
    private let transport: T
    private let encoder: ParameterEncoding
    private let authenticateRequest: ((inout PostRequest) -> Void)?
    private let networkActivityIndicator = NetworkActivityIndicator()

    init(transport: T,
         authenticateRequest: ((inout PostRequest) -> Void)? = nil,
         encoder: ParameterEncoding = URLEncoding.default) {
        self.transport = transport
        self.authenticateRequest = authenticateRequest
        self.encoder = encoder
    }

    func post<Model: Decodable>(request: PostRequest,
                                completion: @escaping (Result<Model, NetworkError>) -> Void) -> CancellationToken {
        var request = request
        if let authenticateRequest = authenticateRequest {
            authenticateRequest(&request)
        }

        networkActivityIndicator.incrementActivityCount()

        let urlRequest = encoder.encode(request, with: request.parameters)
        return transport.dataTask(with: urlRequest) { result in
            assert(!Thread.isMainThread)
            self.networkActivityIndicator.decrementActivityCount()

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(data):
                do {
                    let decoder = JSONDecoder()
                    let languages = try decoder.decode(Model.self, from: data)
                    completion(.success(languages))
                }
                catch {
                    completion(.failure(.generalError(error)))
                }
            }
        }
    }
}
