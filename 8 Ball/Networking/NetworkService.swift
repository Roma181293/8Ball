//
//  NetworkService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation
import CoreText

class NetworkService  {
    static func getData(url: URL, method: String, completion: @escaping ((Data?, Error?) -> Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil,error)
            }
            guard let `data` = data else {completion(nil, ResponseError.noData); return}
            completion(data, nil)
        }
        task.resume()
    }
}
