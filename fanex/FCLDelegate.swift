//
//  FCLDelegate.swift
//  fanex
//
//  Created by aman shah on 26/02/23.
//


import AuthenticationServices
import Foundation

public protocol FCLDelegate {
    func showLoading()
    func hideLoading()
}

extension FCLDelegate {
    func presentationAnchor() -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
