//
//  ViewModelProvaider.swift
//  Transactions
//


import Foundation

struct ViewModelProvaider {
    static func viewModelProduct() -> ProductsViewModel {
        return ProductsViewModel(interactor: InteractorProvaider.getProductInteractor())
    }
}
