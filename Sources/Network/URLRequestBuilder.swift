//
//  URLRequestBuilder.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

private func dictionaryFromEncodable<T: Encodable>(_ value: T) -> [String: Any]? {
    guard
        let data = try? JSONEncoder().encode(value),
        let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    else {
        return nil
    }
    return dictionary
}

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
        
        if let query = request.query, !(query is EmptyParameters),
           let queryDict = dictionaryFromEncodable(query) {
            urlComponents?.queryItems = queryDict.compactMap { (key, value) -> URLQueryItem? in
                guard let convertible = value as? CustomStringConvertible else { return nil }
                return URLQueryItem(name: key, value: convertible.description)
            }
        }
        
        guard let url = urlComponents?.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.headerFields.toDictionary()
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setHTTPBody(from: request.body)
        
        return urlRequest
    }
}
