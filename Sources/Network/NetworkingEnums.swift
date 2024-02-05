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
}
