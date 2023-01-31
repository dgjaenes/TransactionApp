//
//  ViewModelProvaider.swift
//  Transactions
//
//  Created by NEORIS on 31/1/23.
//

import Foundation

struct ViewModelProvaider {
    static func viewModelProduct() -> ProductsViewModel {
        return ProductsViewModel(interactor: InteractorProvaider.getProductInteractor())
    }
}
