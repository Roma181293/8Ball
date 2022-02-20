//
//  RemotePredictionService.swift
//  8 Ball
//
//  Created by Roman Topchii on 14.01.2022.
//

import Foundation

class RemotePredictionService: PredictionProvider {
    
    private let networkDataProvider: NetworkDataProvider!
    
    init(networkDataProvider: NetworkDataProvider) {
        self.networkDataProvider = networkDataProvider
    }
    
    func getPredictionForQuestion(_ question : String? = nil, completion: @escaping ((Predictible?, Error?) -> Void)) {
        
        let apiHost = "https://8ball.delegator.com/"
        let apiPath = "magic/JSON/" + (question ?? "DefaultQuestion")
        
        guard let escapedPath = apiPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed),
              let url = URL(string: "\(apiHost)\(escapedPath)")  else {
                  completion(nil, URLError.invalidURL(url: "\(apiHost)\(apiPath)"))
                  return
              }
        
        networkDataProvider.fetchData(url: url, completion: {(data, error) in
            if let error = error{
                print("ERROR: ", error.localizedDescription)
                completion(nil, error)
            }
            if let data = data{
                do {
                    let remotePredictionData = try JSONDecoder().decode(RemotePredictionData.self, from: data)
                    completion(Prediction(remotePrediction: remotePredictionData.prediction), nil)
                }
                catch let decodingError {
                    completion(nil, decodingError)
                }
            }
        })
    }
}

