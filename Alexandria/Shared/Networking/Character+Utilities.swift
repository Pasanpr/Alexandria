//
//  Character+Utilities.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

extension Character {
    var isUppercase: Bool {
        return String(self) == String(self).uppercased()
    }
}
