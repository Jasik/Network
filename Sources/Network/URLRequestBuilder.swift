//
//  URLRequestBuilder.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public struct URLRequestBuilder {
    
    public init() {}
    
    public func build<Request: HTTPRequest>(from request: Request) -> URLRequest? {
        
        guard let baseURL = request.baseURL else {
            return nil
        }
        
        var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(request.path),
            resolvingAgainstBaseURL: false
        )
        
        urlComponents?.queryItems = request
            .queryParameters?
            .compactMapValues { $0 }
            .compactMap { name, value in
                URLQueryItem(name: name, value: "\(value)")
            }
        
        guard let url = urlComponents?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.allHTTPHeaderFields = request.headerFields.toDictionary()
        urlRequest.httpMethod = request.method.rawValue
        
        urlRequest.setHTTPBody(from: request.bodyParameters)
        
        return urlRequest
    }
}
