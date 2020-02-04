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

protocol DeepLAPI {
    func fetchLanguages(completion: @escaping (Result<[Language], NetworkError>) -> Void) -> CancellationToken
    func translate(text: String,
                   source: Language?,
                   target: Language,
                   completion: @escaping (Result<TranslationResponse, NetworkError>) -> Void) -> CancellationToken
}

enum APIRouter {
    case languages
    case translate

    static var baseURL: URL {
        URL(string: "https://api.deepl.com/v2")!
    }

    var url: URL {
        switch self {
        case .languages:
            return Self.baseURL.appendingPathComponent("languages")
        case .translate:
            return Self.baseURL.appendingPathComponent("translate")
        }
    }
}

final class APIClient<T: Transport>: DeepLAPI {
    private let session: Session<T>

    init(authKey: String, transport: T) {
        session = Session(transport: transport, authenticateRequest: { request in
            request.parameters["auth_key"] = authKey
        })
    }

    func fetchLanguages(completion: @escaping (Result<[Language], NetworkError>) -> Void) -> CancellationToken {
        let request = PostRequest(url: APIRouter.languages.url)
        return session.post(request: request, completion: completion)
    }

    func translate(text: String,
                   source: Language?,
                   target: Language,
                   completion: @escaping (Result<TranslationResponse, NetworkError>) -> Void) -> CancellationToken {
        var parameters = [
            "text": text,
            "target_lang": target.code,
        ]
        if let source = source {
            parameters["source_lang"] = source.code
        }

        let request = PostRequest(url: APIRouter.translate.url, parameters: parameters)
        return session.post(request: request, completion: completion)
    }
}
