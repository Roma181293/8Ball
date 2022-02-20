//
//  NetworkService.swift
//  8 Ball
//
//  Created by Roman Topchii on 19.02.2022.
//

import Foundation
import Alamofire

protocol NetworkDataProvider {
    func fetchData(url: URL, completion: @escaping ((Data?, Error?) -> Void))
}

class NetworkService: NetworkDataProvider {
    func fetchData(url: URL, completion: @escaping ((Data?, Error?) -> Void)) {
        AF.request(url).responseData {(response) in
            if let error = response.error{
                print("ERROR: ", error.localizedDescription)
                completion(nil, error)
            }
            if let responseVal = response.value {
                completion(responseVal, nil)
            }
        }
    }
}
