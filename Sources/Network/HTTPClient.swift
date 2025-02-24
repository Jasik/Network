//
//  HTTPClient.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public protocol HTTPClient {
    func send<Request: HTTPRequest>(_ request: Request, completion: @escaping (Result<Request.Response, HTTPError>) -> Void)
    func send<Request: HTTPRequest>(_ request: Request) async -> Result<Request.Response, HTTPError>
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
                if (error as NSError).code == NSURLErrorTimedOut {
                    completion(.failure(.timeout(response: response as? HTTPURLResponse, data: data)))
                } else {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.failedConnect))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                completion(.failure(.unauthorized(response: httpResponse, data: data)))
                return
            case 403:
                completion(.failure(.forbidden(response: httpResponse, data: data)))
                return
            case 408:
                completion(.failure(.timeout(response: httpResponse, data: data)))
                return
            default:
                completion(.failure(.badHTTPStatus(response: httpResponse, data: data)))
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
    
    public func send<Request: HTTPRequest>(_ request: Request) async -> Result<Request.Response, HTTPError> {
        guard let urlRequest = builder.build(from: request) else {
            return .failure(.invalidRequest)
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.failedConnect)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                return .failure(.unauthorized(response: httpResponse, data: data))
            case 403:
                return .failure(.forbidden(response: httpResponse, data: data))
            case 408:
                return .failure(.timeout(response: httpResponse, data: data))
            default:
                return .failure(.badHTTPStatus(response: httpResponse, data: data))
            }
            
            let result = try request.parse(data: data, response: httpResponse)
            return .success(result)
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                return .failure(.timeout(response: nil, data: nil))
            }
            return .failure(.networkError(error))
        }
    }
}
