//
//  NetworkManager.swift
//  FoodTracker
//
//  Created by Eric Gregor on 2018-02-26.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation

class NetworkManager: NetworkerType {
    
    func requestData(with request: NSMutableURLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request as URLRequest, completionHandler: completionHandler)
        dataTask.resume()
    }
}
