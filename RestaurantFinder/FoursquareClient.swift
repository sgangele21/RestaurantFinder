//
//  FoursquareClient.swift
//  RestaurantFinder
//
//  Created by Pasan Premaratne on 5/5/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

enum Foursquare: Endpoint {
    case venues(VenueEndpoint)
    
    enum VenueEndpoint: Endpoint {
        case search(clientID: String, clientSecret: String, coordinate: Coordinate, category: Category, query: String?, searchRadius: Int?, limit: Int?)
        
        enum Category: CustomStringConvertible {
            case food([FoodCategory]?)
            
            enum FoodCategory: String {
                case Afghan = "503288ae91d4c4b30a586d67"
            }
            
            var description: String {
                switch self {
                case .food(let categories):
                    if let categories = categories {
                        let commaSeparatedString = categories.reduce("") { categoryString, category in
                            "\(categoryString),\(category.rawValue)"
                        }
                        
                        return commaSeparatedString.substring(from: commaSeparatedString.characters.index(commaSeparatedString.startIndex, offsetBy: 1))
                    } else {
                        return "4bf58dd8d48988d17f941735"
                    }
                }
            }
        }
        
        // MARK: Venue Endpoint - Endpoint
        
        var baseURL: String {
            return "https://api.foursquare.com"
        }
        
        var path: String {
            switch self {
            case .search: return "/v2/venues/search"
            }
        }
        
        fileprivate struct ParameterKeys {
            static let clientID = "client_id"
            static let clientSecret = "client_secret"
            static let version = "v"
            static let category = "categoryId"
            static let location = "ll"
            static let query = "query"
            static let limit = "limit"
            static let searchRadius = "radius"
        }
        
        fileprivate struct DefaultValues {
            static let version = "20160301"
            static let limit = "50"
            static let searchRadius = "2000"
        }
        
        var parameters: [String : AnyObject] {
            switch self {
            case .search(let clientID, let clientSecret, let coordinate, let category, let query, let searchRadius, let limit):
                
                var parameters: [String: AnyObject] = [
                    ParameterKeys.clientID: clientID as AnyObject,
                    ParameterKeys.clientSecret: clientSecret as AnyObject,
                    ParameterKeys.version: DefaultValues.version as AnyObject,
                    ParameterKeys.location: coordinate.description as AnyObject,
                    ParameterKeys.category: category.description as AnyObject
                ]
                
                if let searchRadius = searchRadius {
                    parameters[ParameterKeys.searchRadius] = searchRadius as AnyObject?
                } else {
                    parameters[ParameterKeys.searchRadius] = DefaultValues.searchRadius as AnyObject?
                }
                
                if let limit = limit {
                    parameters[ParameterKeys.limit] = limit as AnyObject?
                } else {
                    parameters[ParameterKeys.limit] = DefaultValues.limit as AnyObject?
                }
                
                if let query = query {
                    parameters[ParameterKeys.query] = query as AnyObject?
                }
                
                return parameters
            }
        }
    }
    
    // MARK: Foursquare - Endpoint
    
    var baseURL: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.baseURL
        }
    }
    
    var path: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.path
        }
    }
    
    var parameters: [String : AnyObject] {
        switch self {
        case .venues(let endpoint):
            return endpoint.parameters
        }
    }
}

class FoursquareClient: APIClient {

    let configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    let clientID: String
    let clientSecret: String
    
    init(configuration: URLSessionConfiguration, clientID: String, clientSecret: String) {
        self.configuration = configuration
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    convenience init(clientID: String, clientSecret: String) {
        self.init(configuration: .default, clientID: clientID, clientSecret: clientSecret)
    }
    
    func fetchRestaurantsFor(_ location: Coordinate, category: Foursquare.VenueEndpoint.Category, query: String? = nil, searchRadius: Int? = nil, limit: Int? = nil, completion: @escaping (APIResult<[Venue]>) -> Void) {
        
        let searchEndpoint = Foursquare.VenueEndpoint.search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
        let endpoint = Foursquare.venues(searchEndpoint)
        
        fetch(endpoint, parse: { json -> [Venue]? in
            
            guard let venues = json["response"]?["venues"] as? [[String: AnyObject]] else {
                return nil
            }
            
            return venues.flatMap { venueDict in
                return Venue(JSON: venueDict)
            }
            
            
            }, completion: completion)
    }
}






















