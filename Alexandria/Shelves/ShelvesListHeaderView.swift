//
//  ShelvesListHeaderView.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/28/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

class ShelvesListHeaderView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Palatino-Roman", size: 22.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(titleLabel)
        addSubview(detailButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            detailButton.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            detailButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
        ])
    }

    func titleForHeader(_ title: String, inSection section: Int) {
        titleLabel.text = title
        detailButton.tag = section
    }
    
    func addDetailTarget(_ target: Any?, action: Selector) {
        detailButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
