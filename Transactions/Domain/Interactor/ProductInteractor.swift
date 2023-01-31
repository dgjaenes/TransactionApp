//
//  ProductInteractorProtocol.swift
//  Transactions
//
//  Created by NEORIS on 25/1/23.
//

import Foundation
import Combine
import UIKit

protocol ProductInteractorProtocol {
    func getTransactions() -> AnyPublisher<TransactionsDO, TransactionsAppError>
    func getRates() -> AnyPublisher<RatesDO, TransactionsAppError>
    func filterProduct(transactions: TransactionsDO) -> [Product]
    func getInverseRates(rates: [Rates]) -> [Rates]
    func getTotalAmountToCurrentCurrency(transactions: [TransactionsProduct], ratesItems: [Rates]) -> String
}

class ProductInteractor: ProductInteractorProtocol {
    
    var transactionsRepository: TransactionsRepositoryProtocol
    var ratesRepository: RatesRepositoryProtocol
    var countNotFound = 0
    let cuurentCurrency = "EUR"
    
    init(transactionsRepository: TransactionsRepositoryProtocol, ratesRepository: RatesRepositoryProtocol) {
        self.transactionsRepository = transactionsRepository
        self.ratesRepository = ratesRepository
    }
    
    var products : AnyPublisher<[Product], TransactionsAppError> = Just([])
        .setFailureType(to: TransactionsAppError.self)
        .eraseToAnyPublisher()
    private var disposables = Set<AnyCancellable>()
    
    func getTransactions() -> AnyPublisher<TransactionsDO, TransactionsAppError> {
        transactionsRepository.getTransactions()
    }
    
    func getRates() -> AnyPublisher<RatesDO, TransactionsAppError> {
        ratesRepository.getRates()
    }

    func filterProduct(transactions: TransactionsDO) -> [Product] {
        var products: [Product] = []
        transactions.enumerated().forEach({ index, item in
            if let i = products.firstIndex(where: { $0.sku == item.sku }) {
                products[i].transactions.append(TransactionsProduct(amount: item.amount, currency: item.currency))
            } else {
                products.append(Product(sku: item.sku, transactions: [TransactionsProduct(amount: item.amount, currency: item.currency)]))
            }
        })
        return products
    }
    
    func getInverseRates(rates: [Rates]) -> [Rates] {
        var finalRates = rates
        rates.enumerated().forEach({ index, item in
            let i = rates.firstIndex(where: { $0.from == item.to && $0.to == item.from })
            if i == nil {
                let rate = 1.00 / item.rate
                let newRateItem = Rates(from: item.to, to: item.from, rate: rate)
                finalRates.append(newRateItem)
            }
        })
        return finalRates
    }
    
    func getTotalAmountToCurrentCurrency(transactions: [TransactionsProduct], ratesItems: [Rates]) -> String {
        var amount: Double = 0.0
        transactions.enumerated().forEach { index, item in
            if item.currency == cuurentCurrency {
                amount = amount + item.amount
            } else if let i = ratesItems.firstIndex(where: { $0.from == item.currency && $0.to == cuurentCurrency }) {
                amount = amount + (item.amount * ratesItems[i].rate)
            } else {
                guard let rate = calculateMissingRates(from: item.currency, to: cuurentCurrency, ratesItems: ratesItems) else {
                    return
                }
                amount = amount + (item.amount * rate)
            }
        }
        
        let divisorF = pow(10.0, Double(2))
        let price = ((amount * divisorF).rounded(.down) / divisorF)
        let amountStrint = String(format:"%.2f", price)
        return amountStrint
    }
    
    private func calculateMissingRates(from: String, to: String, ratesItems: [Rates]) -> Double? {
        
        var rate: Double?
        let firtslevelsItems = ratesItems.filter({$0.to == to})
        for item in firtslevelsItems {
            let secondLevelsItems = ratesItems.filter({$0.to == item.from && $0.to != to && $0.from != to})
            for secondItem in secondLevelsItems {
                guard rate == nil else {
                    return rate
                }
                if secondItem.from == from {
                    rate = secondItem.rate * item.rate
                } else {
                    let thirdLevelItems = ratesItems.filter({$0.to == secondItem.from && $0.to != to && $0.from != to})
                    for thirdItem in thirdLevelItems {
                        if thirdItem.from == from {
                            rate = thirdItem.rate * secondItem.rate * item.rate
                        } else {
                            let LevelItems4 = ratesItems.filter({$0.to == thirdItem.from && $0.to != to && $0.from != to})
                            for Item4 in LevelItems4 {
                                if Item4.from == from {
                                    rate = Item4.rate * thirdItem.rate * secondItem.rate * item.rate
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if rate == nil {
            countNotFound = countNotFound + 1
            print("not found: \(from) to: \(to)")
            print("\(countNotFound) not found")
        }
        
        return rate
    }
}
