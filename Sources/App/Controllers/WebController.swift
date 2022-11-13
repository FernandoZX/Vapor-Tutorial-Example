//
//  File.swift
//  
//
//  Created by Fernando Cabrera on 13/11/22.
//

import Foundation
import Vapor

struct CharacterDataModel: Codable {
    let id: Int
    let name: String
    let image: String
}

struct ResultsDataModel: Codable {
    let results: [CharacterDataModel]
}

struct WebController: RouteCollection {
    let uri = URI(string:
        "https://rickandmortyapi.com/api/character")
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("info", use: getInfo)
    }
    
    private func getInfo(_ req: Request) async throws -> View {
        let context: EventLoopFuture<ResultsDataModel> = req.client.get(uri).flatMapThrowing { response -> Data in
            print(response)
            guard response.status == .ok else {
                throw Abort(.notFound)
            }
            guard let buffer = response.body,
                    let data = String(buffer: buffer).data(using: .utf8) else {
                throw Abort(.badRequest)
            }
            return data
        }.map { data in
            let jsonDecoder = JSONDecoder()

            do {
                let dataModel = try jsonDecoder.decode(ResultsDataModel.self, from: data)
                return dataModel
            } catch {
                return ResultsDataModel(results: [])
            }
        }
        
        let dataModel = try await context.get()
        print(dataModel)
        
        return try await req.view.render("index", dataModel)
    }
}
