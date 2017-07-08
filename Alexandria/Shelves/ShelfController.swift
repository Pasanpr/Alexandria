//
//  CurrentlyReadingController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

final class ShelfController: UIViewController {
    
    var credential: OAuthSwiftCredential!
    
    lazy var shelfView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self.dataSource
        view.delegate = self
        view.backgroundColor = .white
        view.separatorColor = .clear
        return view
    }()
    
    private lazy var dataSource: ShelfListDataSource = {
        return ShelfListDataSource(shelves: [], credential: self.credential)
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onViewDidLoad: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Lists"
        
        shelfView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        view.addSubview(shelfView)
        
        if let onViewDidLoad = onViewDidLoad {
            print("Executing onViewDidLoad")
            onViewDidLoad()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            shelfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shelfView.topAnchor.constraint(equalTo: view.topAnchor),
            shelfView.rightAnchor.constraint(equalTo: view.rightAnchor),
            shelfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func updateDataSource(with shelves: [Shelf]) {
        dataSource.update(with: shelves)
        shelfView.reloadData()
        
        for shelf in dataSource.shelves {
            print("Shelf name after reload: \(shelf.shelf.name)")
        }
    }
    
    func updateDataSource(with shelf: Shelf) {
        dataSource.update(with: shelf)
    }
    
    func reloadData() {
        shelfView.reloadData()
        for shelf in dataSource.shelves {
            print("Shelf name after reload: \(shelf.shelf.name)")
        }
    }
}

extension ShelfController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
}
