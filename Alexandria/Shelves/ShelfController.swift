//
//  CurrentlyReadingController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//
import Foundation
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
        
        let font = UIFont(name: "Palatino-Roman", size: 24.0)!
        let attributedStringKey = NSAttributedStringKey(NSAttributedStringKey.font.rawValue)
        navigationController?.navigationBar.titleTextAttributes = [attributedStringKey: font]
        self.title = "Lists"
        
        shelfView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        shelfView.register(CurrentlyReadingCell.self, forCellReuseIdentifier: CurrentlyReadingCell.reuseIdentifier)
        view.addSubview(shelfView)
        
        if let onViewDidLoad = onViewDidLoad {
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
    }
    
    func updateDataSource(with shelf: Shelf) {
        dataSource.update(with: shelf)
    }
    
    func reloadData() {
        shelfView.reloadData()
    }
}

extension ShelfController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 280.0
        default: return 220.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 1.0
        default: return 48
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor(red: 32/255.0, green: 36/255.0, blue: 44/255.0, alpha: 1.0)
            return view
        default:
            let view = ShelvesListHeaderView(frame: .zero)
            let shelf = dataSource.shelf(inSection: section)
            view.titleForHeader(shelf.shelf.prettyName, inSection: section)
            return view
        }
    }
}
