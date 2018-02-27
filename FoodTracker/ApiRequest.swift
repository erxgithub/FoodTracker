//
//  ApiRequest.swift
//  FoodTracker
//
//  Created by Eric Gregor on 2018-02-26.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation

protocol NetworkerType {
    func requestData(with request: NSMutableURLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void)
}

enum ApiError: Error {
    case badURL
    case requestError
    case invalidJSON
}

class ApiRequest {
    
    var networker: NetworkerType
    
    init(networker: NetworkerType) {
        self.networker = networker
    }
}

/// Methods that should be called by other classes
extension ApiRequest {
    
    func loginUser(username: String?, password: String?, completionHandler: @escaping ([String: Any]?, Error?) -> Void)  {
        let postData = [
            "username": username ?? "",
            "password": password ?? ""
        ]
        
        //print(postData["username"]!)
        
        guard let postJSON = try? JSONSerialization.data(withJSONObject: postData, options: []) else {
            print("could not serialize json")
            return
        }
        
        let url = URL(string: "https://cloud-tracker.herokuapp.com/login")!
        let request = NSMutableURLRequest(url: url)
        request.httpBody = postJSON
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.networker.requestData(with: request) { (data, urlRequest, error) in
            
            var json: [String: Any] = [:]
            do {
                json = try self.jsonObject(fromData: data, response: urlRequest, error: error)
            } catch let error {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(json, nil)
        }
        
        return
    }

    func getAllMeals(token: String, completionHandler: @escaping ([[String: Any]]?, Error?) -> Void)  {
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        let request = NSMutableURLRequest(url: url)
        //request.httpBody = nil
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Token")

        self.networker.requestData(with: request) { (data, urlRequest, error) in
            
            var json: [[String: Any]] = [[:]]
            do {
                json = try self.jsonObject2(fromData: data, response: urlRequest, error: error)
            } catch let error {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(json, nil)
        }
        
        return
    }

    func saveMeal(meal: Meal?, completionHandler: @escaping ([String: Any]?, Error?) -> Void)  {
        print(meal as Any)
        return
        
        var name = meal?.name
        let mealDesc = meal?.mealDesc ?? ""
        var calories = meal?.calories
        if calories == nil {
            calories = 0
        }
        
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals?title=\(name))&description=\(mealDesc))&\(calories!)")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.networker.requestData(with: request) { (data, urlRequest, error) in
            
            var json: [String: Any] = [:]
            do {
                json = try self.jsonObject(fromData: data, response: urlRequest, error: error)
            } catch let error {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(json, nil)
        }
        
        return
    }

}

/// JSON Parsing
extension ApiRequest {
    
    func jsonObject(fromData data: Data) throws -> [String: Any] {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let results = jsonObject as? [String: Any] else {
            throw ApiError.invalidJSON
        }
        
        return results
    }
    
    func jsonObject2(fromData data: Data) throws -> [[String: Any]] {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let results = jsonObject as? [[String: Any]] else {
            throw ApiError.invalidJSON
        }
        
        return results
    }
    
    func jsonObject(fromData data: Data?, response: URLResponse?, error: Error?) throws -> [String: Any] {
        if let error = error {
            throw error
        }
        guard let data = data else {
            throw ApiError.requestError
        }
        
        return try jsonObject(fromData: data)
    }
    
    func jsonObject2(fromData data: Data?, response: URLResponse?, error: Error?) throws -> [[String: Any]] {
        if let error = error {
            throw error
        }
        guard let data = data else {
            throw ApiError.requestError
        }
        
        return try jsonObject2(fromData: data)
    }

}
