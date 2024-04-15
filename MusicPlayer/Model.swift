//
//  Model.swift
//  MusicPlayer
//
//  Created by Chase Kellogg on 4/3/24.
//

import Foundation

class Model {
    func getVideos(searchQuery: String, completion: @escaping ([Video]) -> Void) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&q=\(searchQuery)&type=video&key=\(Constants.API_KEY)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared

        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            if data == nil {
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(Response.self, from: data)
                    completion(response.items ?? [])
                } catch {
                    print("Error parsing data: \(error.localizedDescription)")
                }
            }
            
//
//            // TODO: Parsing the data into video objects
        }

        dataTask.resume()
    }
}
