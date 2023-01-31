//
//  InteractorProvaider.swift
//  Transactions
//
//  Created by NEORIS on 31/1/23.
//

import Foundation

struct InteractorProvaider {
    static func getProductInteractor() -> ProductInteractorProtocol {
        return ProductInteractor(transactionsRepository: TransactionsRepository(), ratesRepository: RatesRepository())
    }
}
