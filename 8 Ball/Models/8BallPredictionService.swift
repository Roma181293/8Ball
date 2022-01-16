//
//  8BallPredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation
import Alamofire

class EightBallPredictionService {
    
    static func getPredictionForQuestion(_ question : String? = nil, completion: @escaping ((MagicData?, Error?) -> Void)) {
        
        let apiHost = "https://8ball.delegator.com/"
        let apiPath = "magic/JSON/" + (question ?? "Question")
        
        guard let escapedPath = apiPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed),
              let url = URL(string: "\(apiHost)\(escapedPath)")  else {
                  completion(nil, URLError.invalidURL(url: "\(apiHost)\(apiPath)"))
                  return
              }
        
        AF.request(url).responseDecodable(of: MagicData.self) {(response) in
            if let error = response.error{
                print("ERROR: ", error.localizedDescription)
                completion(nil, error)
            }
            if let magicData = response.value {
                completion(magicData, nil)
            }
        }
    }
}
