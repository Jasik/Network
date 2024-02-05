//
//  HTTPClient.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

protocol HTTPClient {
    func send<Request: HTTPRequest>(_ request: Request, completion: @escaping (Result<Request.Response, HTTPError>) -> Void)
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let builder: URLRequestBuilder

    init(session: URLSession = .shared, builder: URLRequestBuilder = URLRequestBuilder()) {
        self.session = session
        self.builder = builder
    }

    func send<Request: HTTPRequest>(_ request: Request, completion: @escaping (Result<Request.Response, HTTPError>) -> Void) {
        guard let urlRequest = builder.build(from: request) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let data = data, error == nil else {
                completion(.failure(.networkError(error!)))
                return
            }

            do {
                let result = try request.parse(data: data, response: httpResponse)
                completion(.success(result))
            } catch {
                completion(.failure(.parseError(error)))
            }
        }
        task.resume()
    }
}
