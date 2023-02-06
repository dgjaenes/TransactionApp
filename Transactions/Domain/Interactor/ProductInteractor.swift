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
    func getMissingRates(rates: [Rates]) -> [Rates]
    func getTotalAmountToCurrentCurrency(transactions: [TransactionsProduct], ratesItems: [Rates]) -> String
}

class ProductInteractor: ProductInteractorProtocol {
    
    var transactionsRepository: TransactionsRepositoryProtocol
    var ratesRepository: RatesRepositoryProtocol
    var countNotFound = 0
    let cuurentCurrency = "EUR"
    var ratesChecked: [Rates] =  []
    
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
    
    func getMissingRates(rates: [Rates]) -> [Rates] {
        ratesChecked = getInverseRates(rates: rates)
        let filterRates = ratesChecked.filter({$0.from != cuurentCurrency && $0.to != cuurentCurrency})
        for item in filterRates {
            calculateMissingRates(ratesItems: filterRates.filter({$0.from == item.from}), ratePreviuos: 1, rate: item.from)
        }
        return getInverseRates(rates: ratesChecked)
    }
    
    func getTotalAmountToCurrentCurrency(transactions: [TransactionsProduct], ratesItems: [Rates]) -> String {
        var amount: Double = 0.0
        transactions.enumerated().forEach { index, item in
            if item.currency == cuurentCurrency {
                amount = amount + item.amount
            } else if let i = ratesItems.firstIndex(where: { $0.from == item.currency && $0.to == cuurentCurrency }) {
                amount = amount + (item.amount * ratesItems[i].rate)
            } else {
                amount = 0.0
            }
        }
        
        let divisorF = pow(10.0, Double(2))
        let price = ((amount * divisorF).rounded(.down) / divisorF)
        let amountStrint = String(format:"%.2f", price)
        return amountStrint
    }
    
    func calculateMissingRates(ratesItems: [Rates], ratePreviuos: Double, rate: String) {
        for item in ratesItems {
            if item.to == cuurentCurrency {
                ratesChecked.append(Rates(from: rate, to: cuurentCurrency, rate: item.rate * ratePreviuos))
                return
            } else {
                guard !ratesChecked.contains(where: {$0.from == rate && $0.to == cuurentCurrency}) else {
                    return
                }
                let filerRates = ratesChecked.filter({$0.from == item.to})
                calculateMissingRates(ratesItems: filerRates, ratePreviuos: item.rate * ratePreviuos, rate: item.from)
            }
        }
    }
}
