//
//  ViewController.swift
//  Transactions
//

import UIKit
import Combine

class ViewController: UIViewController { 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var initLabel: UILabel!
    
    private var dataSourceSubscriber: AnyCancellable?
    var viewModel = ViewModelProvaider.viewModelProduct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        dataSourceSubscriber = viewModel.$productsCell
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [self] items in
                initLabel.text = "Products"
                tableView.reloadData()
            })
        viewModel.getProducts()
    }
    
    func configTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let model = viewModel.productsCell[indexPath.row]
        
        var listContentConfiguration = UIListContentConfiguration.subtitleCell()
        listContentConfiguration.text = model.title
        listContentConfiguration.secondaryText = model.subtitle
        
        cell.contentConfiguration = listContentConfiguration
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.productsCell.count
    }
}
