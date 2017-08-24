//
//  NetworkClient.swift
//  BranTreeDemo
//
//  Created by Thuc on 8/24/17.
//  Copyright © 2017 Nguyen Thanh Thuc. All rights reserved.
//

import UIKit

enum NetworkError: Error {
    case invalidURL
    case generic
}

protocol NetworkClientProtocol {
    func sendRequest(request: URLRequest, 
                     completion: @escaping(Data?, URLResponse?, Error?) -> Void)
}

class NetworkClient: NetworkClientProtocol {
	
    static let sharedInstance = NetworkClient()
    
    var session: URLSession!
    
    // MARK: - Initialisers
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 120.0
        
        session = URLSession(configuration: .default)
    }
    
    func sendRequest(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        if let existingHeaders = request.allHTTPHeaderFields {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
            configuration.timeoutIntervalForRequest = 120.0
            configuration.httpAdditionalHeaders = existingHeaders
            session = URLSession(configuration: configuration)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }
        task.resume()
        
    }
}
