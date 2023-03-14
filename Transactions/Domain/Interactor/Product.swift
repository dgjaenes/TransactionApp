//
//  Product.swift
//  Transactions
//

import Foundation
import UIKit

struct Product {
    let sku: String
    var transactions: [TransactionsProduct]
    var totalAmount: String = "0"
}

struct TransactionsProduct {
    let amount: Double
    let currency: String
}
