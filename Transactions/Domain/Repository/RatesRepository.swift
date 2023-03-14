//
//  RatesRepositoryImplement.swift
//  Transactions
//

import Foundation
import Combine

protocol RatesRepositoryProtocol {
    func getRates() -> AnyPublisher<RatesDO, TransactionsAppError>
}

class RatesRepository: ManagerTransactionsAppRepository, RatesRepositoryProtocol {

    struct RatesAPI {
        static let scheme = "http"
        static let host = "android-ios-service.herokuapp.com"
        static let path = "/rates"
    }
    
    func makeUrltComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = RatesAPI.scheme
        components.host = RatesAPI.host
        components.path = RatesAPI.path
        
        return components
    }
    
    func getRates() -> AnyPublisher<RatesDO, TransactionsAppError> {
        return execute(components: makeUrltComponents())
    }
}
