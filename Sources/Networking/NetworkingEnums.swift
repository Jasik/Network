//
//  NetworkingEnums.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public enum HTTPMethod: String, Sendable {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case head    = "HEAD"
    case options = "OPTIONS"
}

public enum HTTPContentType: String, Sendable {
    case json              = "application/json"
    case html              = "text/html"
    case xml               = "application/xml"
    case multipartFormData = "multipart/form-data"
    case urlEncoded        = "application/x-www-form-urlencoded"
    case plain             = "text/plain"
}

public enum HTTPHeader: String, Sendable {
    case contentType    = "Content-Type"
    case accept         = "Accept"
    case authorization  = "Authorization"
    case acceptEncoding = "Accept-Encoding"
    case cacheControl   = "Cache-Control"
    case userAgent      = "User-Agent"
}
