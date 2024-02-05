//
//  URLRequestBuilder.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

struct URLRequestBuilder {
    
    func build<Request: HTTPRequest>(from request: Request) -> URLRequest? {
        
        guard let baseURL = request.baseURL else {
            return nil
        }
        
        var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(request.path),
            resolvingAgainstBaseURL: false
        )
        
        urlComponents?.queryItems = request
            .queryParameter?
            .compactMapValues { $0 }
            .compactMap { name, value in
                URLQueryItem(name: name, value: "\(value)")
            }
        
        guard let url = urlComponents?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        var allHTTPHeaderFields = request.headerFields?.toDictionary() ?? [:]
        allHTTPHeaderFields[HTTPHeaderFields.contentType] = request.contentType.rawValue
        
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setHTTPBody(from: request.bodyParameter)
        
        return urlRequest
    }
}
