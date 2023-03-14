//
//  ProductCellViewModel.swift
//  Transactions
//

import Foundation
import UIKit

struct ProductCellViewModel {
    let title: String
    let subtitle: String
    
    init(product: Product) {
        title = product.sku + "  Transactions: " + String(product.transactions.count)
        subtitle = "Total amount: " + String(product.totalAmount)
    }
}
