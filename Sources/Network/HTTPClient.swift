//
//  HTTPClient.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public protocol HTTPClient {
    func send<Request: HTTPRequest>(_ request: Request, completion: @escaping (Result<Request.Response, HTTPError>) -> Void)
}

public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let builder: URLRequestBuilder

    public init(session: URLSession = .shared, builder: URLRequestBuilder = URLRequestBuilder()) {
        self.session = session
        self.builder = builder
    }

    public func send<Request: HTTPRequest>(_ request: Request, completion: @escaping (Result<Request.Response, HTTPError>) -> Void) {
        guard let urlRequest = builder.build(from: request) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.failedConnect))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.badHTTPStatus(httpResponse.statusCode)))
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
