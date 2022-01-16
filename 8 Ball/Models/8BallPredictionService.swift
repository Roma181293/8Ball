//
//  8BallPredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

class EightBallPredictionService {
    
    static func getPredictionForQuestion(_ question : String? = nil, completion: @escaping ((MagicData?, Error?) -> Void)) {
        
        let quest = question?.replacingOccurrences(of: " ", with: "%20")
        
        let stringURL = "https://8ball.delegator.com/magic/JSON/" + (quest ?? "Question")
        guard let url = URL(string: stringURL) else {completion(nil, URLError.badURL(url: stringURL)); return}
        
        NetworkService.getData(url: url, method: "GET", completion: { (data, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(#function, error.localizedDescription)
                    completion(nil, error)
                }
                
                guard let data = data else {return}
                
                do {
                    let data = try JSONDecoder().decode(MagicData.self, from: data)
                    completion(data, nil)
                } catch let decodingError {
                    print(#function, decodingError.localizedDescription)
                    completion(nil, decodingError)
                }
            }
        })
    }
}
