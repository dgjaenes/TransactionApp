//
//  RatesRepositoryMock.swift
//  TransactionsTests
//

import Foundation
@testable import Transactions
import Combine

class RatesRepositoryMock: RatesRepository {
    
    let mockRepository = ManagerTransactionsAppRepositoryMock.shared
    
    override func execute<T>(components: URLComponents) -> AnyPublisher<T, TransactionsAppError> where T: Decodable {
        return mockRepository.execute(components: components)
    }
}
