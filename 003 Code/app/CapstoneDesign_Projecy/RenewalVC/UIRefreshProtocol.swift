//
//  UIRefreshProtocol.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 10/17/23.
//

import Foundation
protocol ViewControllerDelegate: AnyObject {
    func refreshUIOnViewController()
}
protocol ViewControllerDelegate_completion: AnyObject {
    func refreshUIOnViewController(completion: @escaping () -> Void)
}
