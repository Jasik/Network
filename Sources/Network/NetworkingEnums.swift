//
//  NetworkingEnums.swift
//  
//
//  Created by Vladimir Rogozhkin on 2024/02/05.
//

import Foundation

public enum HTTPMethod: String {
    case get, post, put, delete
}

public enum HTTPContentType: String {
    case applicationJSON = "application/json"
    case textHTML = "text/html"
    case applicationXML = "application/xml"
    case multipartFormData = "multipart/form-data"
    case urlEncoded = "application/x-www-form-urlencoded"
    case textPlain = "text/plain"
}

public enum HTTPHeaderKey: String {
    case contentType = "Content-Type"
    case accept = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case cacheControl = "Cache-Control"
}
