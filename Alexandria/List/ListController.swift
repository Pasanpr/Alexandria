//
//  ListController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/28/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

class ListController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let screenWidth = UIScreen.main.bounds.width
        let horizontalConstraintConstant: CGFloat = 8.0
        let interItemSpacing: CGFloat = 8.0
        let collectionViewWidth = screenWidth - (horizontalConstraintConstant * 2)
        let itemWidth = (collectionViewWidth - (interItemSpacing * 2))/3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(BookCell.self, forCellWithReuseIdentifier: BookCell.reuseIdentifier)
        view.backgroundColor = .white
        return view
    }()
    
    var dataSource: ListDataSource?
    var onReviewSelect: ((GoodreadsReview) -> Void)?
    
    init(dataSource: ListDataSource?) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        self.init(dataSource: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // FIXME: Refactor
        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()

        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        collectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let review = dataSource?.review(at: indexPath) else { return }
        onReviewSelect?(review)
    }
}
