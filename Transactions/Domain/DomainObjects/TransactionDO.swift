//
//  TransactionDO.swift
//  Transactions
//
//  Created by NEORIS on 24/1/23.
//

import Foundation

// MARK: - TransactionsDOElement
struct TransactionsDOElement: Codable, Equatable {
    let sku: String
    let amount: Double
    let currency: String
}

typealias TransactionsDO = [TransactionsDOElement]
