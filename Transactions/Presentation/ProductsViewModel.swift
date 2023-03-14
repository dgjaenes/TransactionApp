//
//  ProductViewModel.swift
//  Transactions
//

import Foundation
import Combine

class ProductsViewModel {
    @Published var productsCell: [ProductCellViewModel] = []
    
    private let interactor: ProductInteractorProtocol
    private var disposables = Set<AnyCancellable>()
    private var transactions : TransactionsDO?
    private var products: [Product]?
    private var rates: [Rates]?
    
    init(interactor: ProductInteractorProtocol, scheduler: DispatchQueue = DispatchQueue(label: "ProductsViewModel")) {
        self.interactor = interactor
    }
    
    func getProducts(){
        interactor.getTransactions()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] results in
                    self?.products = self?.interactor.filterProduct(transactions: results)
                    if self?.products != nil && self?.rates != nil {
                        self?.setProductView()
                    }
                })
            .store(in: &disposables)
        
        interactor.getRates()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] results in
                    self?.rates = results
                    if self?.transactions != nil && self?.rates != nil {
                        self?.setProductView()
                    }
                })
            .store(in: &disposables)
    }
    
    private func setProductView() {
        guard let rates = self.rates else {return}
        let finalRates = interactor.getMissingRates(rates: rates)
        self.products = self.products?.map({ Product(sku: $0.sku,
                                                    transactions: $0.transactions,
                                                    totalAmount: interactor.getTotalAmountToCurrentCurrency(
                                                        transactions: $0.transactions,
                                                        ratesItems: finalRates))})
        productsCell = products?.map({ProductCellViewModel(product: $0)}) ?? []
    }
}

