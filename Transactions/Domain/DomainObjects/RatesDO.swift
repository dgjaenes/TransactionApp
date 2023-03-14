//
//  RatesDO.swift
//  Transactions
//

import Foundation

// MARK: - RatesDOElement
struct Rates: Codable {
    let from, to: String
    let rate: Double
}

typealias RatesDO = [Rates]
