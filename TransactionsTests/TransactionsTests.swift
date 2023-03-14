//
//  TransactionsTests.swift
//  TransactionsTests


import XCTest
@testable import Transactions
import Combine

class TransactionsTests: XCTestCase {
    
    private var disposables = Set<AnyCancellable>()
    private var interactor: ProductInteractor!
    private var viewModelTest: ProductsViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        interactor = ProductInteractor(transactionsRepository: TransactionsRepositoryMock(), ratesRepository: RatesRepositoryMock())
        viewModelTest = ProductsViewModel(interactor: interactor)
    }
    
    override func tearDownWithError() throws {
        interactor = nil
        viewModelTest = nil
        try super.setUpWithError()
    }
    
    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
    func testProductsCellViewModel() throws {
        
        let expectation = XCTestExpectation(description: "Products are update")
        
        viewModelTest.$productsCell.dropFirst().sink { items in
            XCTAssertEqual(items.count, 2)
            XCTAssertTrue(items[0].title.contains("X001"))
            XCTAssertTrue(items[0].title.contains("Transactions: 2"))
            XCTAssertTrue(items[1].subtitle.contains("Total amount"))
            XCTAssertTrue(items[0].title.contains("Transactions: 2"))
            expectation.fulfill()
        }.store(in: &disposables)
        
        let transactions1 = [
            TransactionsProduct(amount: 50.0, currency: "CAD"),
            TransactionsProduct(amount: 20.0, currency: "EUR")]
        let transactions2 = [
            TransactionsProduct(amount: 30.0, currency: "EUR"),
            TransactionsProduct(amount: 60.0, currency: "CAD")]
        
        let productCells = [
            ProductCellViewModel(product: Product(sku: "X001", transactions: transactions1)),
            ProductCellViewModel(product: Product(sku: "X002", transactions: transactions2))]
        
        viewModelTest.productsCell = productCells
        
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testInteractorTransactions() throws {
        
        var transactions: [TransactionsDOElement] = []
        let error: Error? = nil
        let expectation = self.expectation(description: "Get transactions")
        
        interactor.getTransactions()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                
                expectation.fulfill()
            }, receiveValue: { value in
                transactions = value
            })
            .store(in: &disposables)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(error)
        XCTAssertEqual(transactions.count, 2)
        
        let product = interactor.filterProduct(transactions: transactions)
        XCTAssertTrue(product.count == 2)
    }
    
    func testInteractorRates() throws {
        
        var rates: [Rates] = []
        let error: Error? = nil
        let expectation = self.expectation(description: "Get rates")
        
        interactor.getRates()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                
                expectation.fulfill()
            }, receiveValue: { value in
                rates = value
            })
            .store(in: &disposables)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(error)
        XCTAssertEqual(rates.count, 6)
        
        let finalRates = interactor.getMissingRates(rates: rates)
        XCTAssertTrue(finalRates.count == 10)
    }
}
