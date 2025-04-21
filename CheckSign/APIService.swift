//
//  APIService.swift
//  CheckSign
//
//  Created by Connor Gallaspy on 4/20/25.
//

import Foundation
import SwiftyJSON

// MARK: – DTOs that match the API payload
struct OrgDTO: Decodable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let members: [String]
}

// MARK: – Thin JSON layer (Codable + URLSession)
actor APIService {
    static let shared = APIService()                        // singleton for simplicity
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase       // handles snake_case keys :contentReference[oaicite:0]{index=0}
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    func fetchOrgs(for userID: String) async throws -> [OrgDTO] {
        guard let url = URL(string: "https://api.checksign.app/orgs?user=\(userID)") else { throw URLError(.badURL) }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        let json = try JSON(data: data)
        return json.arrayValue.compactMap { j in
            guard let id = j["id"].string,
                  let name = j["name"].string else { return nil }
            return OrgDTO(id: id,
                          name: name,
                          latitude: j["latitude"].doubleValue,
                          longitude: j["longitude"].doubleValue,
                          members: j["members"].arrayValue.compactMap(\.string))
        }
    }
}
