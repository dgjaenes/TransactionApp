//
//  TransactionDO.swift
//  Transactions
//


import Foundation

// MARK: - TransactionsDOElement
struct TransactionsDOElement: Codable, Equatable {
    let sku: String
    let amount: Double
    let currency: String
}

typealias TransactionsDO = [TransactionsDOElement]
