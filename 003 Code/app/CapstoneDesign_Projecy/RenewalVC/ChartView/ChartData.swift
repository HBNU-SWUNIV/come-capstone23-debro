//
//  ChartData.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 10/18/23.
//

import Foundation

struct ChartData: Identifiable, Codable {
    var id = UUID()
    var date: String
    var value: Double
}

