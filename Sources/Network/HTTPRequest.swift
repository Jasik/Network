//
//  HTTPRequest.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public protocol HTTPRequest {
    associatedtype Response: Decodable
    
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headerFields: HTTPHeaderFields { get }
    var queryParameters: [String: Any?]? { get }
    var bodyParameters: [String: Any]? { get }
    
    var decoder: JSONDecoder { get }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response
}

public extension HTTPRequest where Response: Decodable {
    
    var method: HTTPMethod {
        .get
    }
    
    var headerFields: HTTPHeaderFields? {
        .defaultHeaders()
    }
    
    var contentType: HTTPContentType {
        .applicationJSON
    }
    
    var queryParameter: [String : Any?]? {
        nil
    }
    
    var bodyParameter: [String : Any]? {
        nil
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response {
        return try decoder.decode(Response.self, from: data)
    }
}
