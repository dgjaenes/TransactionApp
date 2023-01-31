//
//  Product.swift
//  Transactions
//
//  Created by NEORIS on 26/1/23.
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
