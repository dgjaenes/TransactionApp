//
//  ProductCellViewModel.swift
//  Transactions
//
//  Created by NEORIS on 31/1/23.
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
