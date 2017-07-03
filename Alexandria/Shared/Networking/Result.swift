//
//  Result.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}


