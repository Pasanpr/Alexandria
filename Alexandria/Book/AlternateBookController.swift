//
//  AlternateBookController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 9/16/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class AlternateBookController: UIViewController {
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bottomFixedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let review: GoodreadsReview
    
    init(review: GoodreadsReview) {
        self.review = review
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init coder not implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = .green
        
        let tableViewHeaderView = UIView()
        tableViewHeaderView.backgroundColor = .blue
        
        tableView.tableHeaderView = tableViewHeaderView
        let tableViewHeaderViewFrame = tableViewHeaderView.frame
        tableViewHeaderView.frame = CGRect(x: tableViewHeaderViewFrame.origin.x, y: tableViewHeaderViewFrame.origin.y, width: tableViewHeaderViewFrame.size.width, height: 200)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(tableView)
        view.addSubview(bottomFixedView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomFixedView.topAnchor),
            bottomFixedView.heightAnchor.constraint(equalToConstant: 64.0),
            bottomFixedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFixedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFixedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension AlternateBookController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return BookCoverCell(review: self.review, blurredBackground: true)
        default: return UITableViewCell()
        }
    }
}

extension AlternateBookController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            let screenBounds = UIScreen.main.bounds
            let verticalPadding: CGFloat = 16.0
            return ((screenBounds.width/2) * 1.5) + (verticalPadding * 2)
        default: return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return UITableViewAutomaticDimension
        }
    }
}
