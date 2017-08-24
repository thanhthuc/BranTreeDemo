
//
//  API.swift
//  BranTreeDemo
//
//  Created by iOS Developer on 8/21/17.
//  Copyright © 2017 Nguyen Thanh Thuc. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum BTAPIEndPoint {
    
    case fetchMerchantConfig
    case createCustomer
    case getClientToken
    case checkout    
}

extension BTAPIEndPoint {
    
    var baseURL: String {
     	return "http://localhost:8000"   
    }
    
    var url: URL? {
        switch self {
        case .createCustomer:
            return URL(string: "\(baseURL)/createCustomer")
        case .fetchMerchantConfig:
            return URL(string: "\(baseURL)/fetch_merchant_config")
        case .getClientToken:
            return URL(string: "\(baseURL)/client_token") 
        case .checkout:
            return URL(string:"\(baseURL)/checkout")
        }
    }
    
    var httpMethod: String {
        switch self {
        case .getClientToken:
            return HTTPMethod.get.rawValue
        default:
            return HTTPMethod.post.rawValue
        }
    }
    
}
