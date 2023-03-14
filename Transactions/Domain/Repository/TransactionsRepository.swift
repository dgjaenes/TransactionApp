//
//  ProductsRepository.swift
//  Transactions
//


import Foundation
import Combine

protocol TransactionsRepositoryProtocol {
    func getTransactions() -> AnyPublisher<TransactionsDO, TransactionsAppError>
}

class TransactionsRepository: ManagerTransactionsAppRepository, TransactionsRepositoryProtocol {
    
    struct TransactionsAPI {
        static let scheme = "http"
        static let host = "android-ios-service.herokuapp.com"
        static let path = "/transactions"
    }
    
    func getTransactions() -> AnyPublisher<TransactionsDO, TransactionsAppError> {
        return execute(components: makeUrltComponents())
    }
    
    func makeUrltComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = TransactionsAPI.scheme
        components.host = TransactionsAPI.host
        components.path = TransactionsAPI.path
        
        return components
    }
}
