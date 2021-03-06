//
//  Router.swift
//  RPAppStoreFeedback
//
//  Created by Michael Orcutt on 7/9/17.
//  Copyright © 2017 Michael Orcutt. All rights reserved.
//

import Alamofire
import CoreLocation

public enum RPFeedbackRouter: URLRequestConvertible {
    
    // MARK: – Cases
    
    case feedback(RPFeedbackModel, RPSettings)
    case locations(CLLocation?, RPSettings)

    // MARK: – Method
    
    var method: HTTPMethod {
        
        switch self {
        case .feedback(_):
            return .post
        case .locations(_, _):
            return .get
        }

    }
    
    // MARK: - URL
    
    var path: String {
        
        switch self {
        case .feedback(_):
            return "feedback"
        case .locations(_, _):
            return "locations"
        }
        
    }
    
    // MARK: - Parameters
    
    var parameters: Parameters {
        
        var parameters : [String:Any] = [:]
        
        switch self {
        case .feedback(let feedback, _):
            
            if let locationID = feedback.locationID {
                parameters["location_id"] = locationID
            }

            if let review = feedback.text {
                parameters["review"] = review
            }
            
            if let review = feedback.rating {
                parameters["rating"] = review
            }

            if let reviewer = feedback.reviewer {
                parameters["reviewer"] = reviewer
            }

            if let email = feedback.email {
                parameters["email"] = email
            }

            parameters["metadata"] = ["will_share": feedback.meta.willShare]
            
        case .locations(let point, _):
            
            guard let point = point else {
                break
            }
            
            parameters["latitude"]  = point.coordinate.latitude
            parameters["longitude"] = point.coordinate.longitude

        }
        
        return parameters
        
    }
    
    // MARK: – Request
    
    public func asURLRequest() throws -> URLRequest {
        
        let url = try "https://dashboard.reviewpush.com/api/company".asURL()
        
        var urlRequest        = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        switch self {
        case .feedback(_, let settings), .locations(_, let settings):
            
            guard let APISecret = settings.APISecret, let APIKey = settings.APIKey else {
                break
            }
            
            urlRequest.addValue(APIKey, forHTTPHeaderField: "X-Api-Key")
            urlRequest.addValue(APISecret, forHTTPHeaderField: "X-Api-Secret")
            
        }
        
        urlRequest.httpBody = jsonData
        
        return try URLEncoding.default.encode(urlRequest, with: nil)
        
    }
    
}
