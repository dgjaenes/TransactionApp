//
//  RatesDO.swift
//  Transactions
//
//  Created by NEORIS on 24/1/23.
//

import Foundation

// MARK: - RatesDOElement
struct Rates: Codable {
    let from, to: String
    let rate: Double
}

typealias RatesDO = [Rates]
