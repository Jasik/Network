//
//  HTTPRequest.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public struct EmptyParameters: Encodable {}

public protocol HTTPRequest {
    associatedtype Response: Decodable
    associatedtype Query: Encodable = EmptyParameters
    associatedtype Body: Encodable = EmptyParameters
    
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headerFields: HTTPHeaderFields { get }
    var query: Query? { get }
    var body: Body? { get }
    
    var decoder: JSONDecoder { get }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response
}

public extension HTTPRequest where Response: Decodable {
    
    var method: HTTPMethod {
        .get
    }
    
    var headerFields: HTTPHeaderFields {
        .defaultHeaders()
    }
    
    var query: Query? {
        nil
    }
    
    var body: Body? {
        nil
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
    
    func parse(data: Data, response: HTTPURLResponse) throws -> Response {
        return try decoder.decode(Response.self, from: data)
    }
}
