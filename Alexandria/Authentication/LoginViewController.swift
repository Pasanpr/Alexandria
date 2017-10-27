//
//  LoginViewController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginViewController: UIViewController {
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor("#20242C")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lists"
        label.font = UIFont(name: "Palatino-Roman", size: 80.0)!
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "powered by"
        return label
    }()
    
    lazy var goodreadsImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "GoodreadsLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, goodreadsImageView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.setCustomSpacing(8.0, after: subtitleLabel)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            goodreadsImageView.widthAnchor.constraint(equalToConstant: 1/3 * UIScreen.main.bounds.width),
            goodreadsImageView.heightAnchor.constraint(equalTo: goodreadsImageView.widthAnchor, multiplier: 1/4.7),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 64)
        ])
        
    }
}
