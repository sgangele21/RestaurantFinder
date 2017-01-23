//
//  APIClient.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/4/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

public let TRENetworkingErrorDomain = "com.treehouse.Stormy.NetworkingError"

public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

public protocol JSONDecodable {
    init?(JSON: [String : AnyObject])
}

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }
}

public extension Endpoint {
    var queryComponents: [URLQueryItem] {
        var components = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.append(queryItem)
        }
        
        return components
    }
    
    var request: URLRequest {
        var components = URLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryComponents

        
        let url = components.url!
        return URLRequest(url: url)
    }
}

public typealias JSON = [String: AnyObject]
public typealias JSONCompletion = (JSON?, HTTPURLResponse?, NSError?) -> Void
public typealias JSONTask = URLSessionDataTask

public enum APIResult<T> {
    case success(T)
    case failure(Error)
}

public protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWithRequest(_ request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(_ endpoint: Endpoint, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void)
}

public extension APIClient {
    
    public func JSONTaskWithRequest(_ request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error as NSError?)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                        completion(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        completion(nil, HTTPResponse, error)
                    }
                default:
                    print("Received HTTP response: \(HTTPResponse.statusCode), which was not handled")
                }
            }
        })
        
        return task
    }
    
    public func fetch<T: JSONDecodable>(_ endpoint: Endpoint, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
        
        let request = endpoint.request
        
        let task = JSONTaskWithRequest(request) { json, response, error in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // TODO: Implement error handling
                    }
                    return
                }
                
                if let resource = parse(json) {
                    completion(.success(resource))
                } else {
                    let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        
    }
    
}





















