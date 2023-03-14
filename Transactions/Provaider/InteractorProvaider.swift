//
//  InteractorProvaider.swift
//  Transactions
//

import Foundation

struct InteractorProvaider {
    static func getProductInteractor() -> ProductInteractorProtocol {
        return ProductInteractor(transactionsRepository: TransactionsRepository(), ratesRepository: RatesRepository())
    }
}
