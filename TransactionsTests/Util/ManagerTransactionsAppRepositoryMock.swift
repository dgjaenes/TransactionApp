//
//  ManagerTransactionsAppRepositoryMock.swift
//  TransactionsTests
//
//  Created by NEORIS on 14/3/23.
//

import Foundation
@testable import Transactions
import Combine

class ManagerTransactionsAppRepositoryMock {
    
    static let shared = ManagerTransactionsAppRepositoryMock()
    
    func execute<T>(components: URLComponents) -> AnyPublisher<T, TransactionsAppError> where T: Decodable {
        let session = URLSessionMock()
        
        return session.dataTaskPublisher(jsonName: components.path.replacingOccurrences(of: "/", with: ""))
            .mapError { error in
            .network(description: error.localizedDescription)
            }
            .print()
            .map { data, response  in
                return data
            }
            .flatMap() { item in
                self.decode(item)
            }
            .eraseToAnyPublisher()
    }
    
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, TransactionsAppError> {
        let decoder = JSONDecoder()
        
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
            .parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

protocol URLSessionMockPublisher {
    func dataTaskPublisher(jsonName: String) -> URLSession.DataTaskPublisher
}

class URLSessionMock: URLSessionMockPublisher {
    func dataTaskPublisher(jsonName: String) -> URLSession.DataTaskPublisher {

        return URLSession.shared.dataTaskPublisher(for: Bundle(for: type(of: self)).url(forResource: jsonName, withExtension: "json")!)
    }
}

