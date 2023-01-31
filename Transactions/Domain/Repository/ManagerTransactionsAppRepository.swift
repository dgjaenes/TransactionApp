//
//  ManagerTransactionsAppRepository.swift
//  Transactions
//

import Foundation
import Combine

class ManagerTransactionsAppRepository {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    internal func execute<T>(components: URLComponents) -> AnyPublisher<T, TransactionsAppError> where T: Decodable {
        guard let url = components.url else {
            let error = TransactionsAppError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return session.dataTaskPublisher(for: request)
            .mapError { error in
            .network(description: error.localizedDescription)
            }
            .print()
            .map { data, response  in
                guard let response = response as? HTTPURLResponse else {
                    print("error httpUrlResponse")
                    return data
                }
                guard 200..<300 ~= response.statusCode else {
                    print(response.statusCode)
                    return data
                }
                return data
            }
            .flatMap() { item in
                self.decode(item)
            }
            .eraseToAnyPublisher()
    }
    
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, TransactionsAppError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
            .parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

enum TransactionsAppError: Error {
    case parsing(description: String)
    case network(description: String)
}
