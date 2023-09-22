//
//  PlantCustomButton.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/09/06.
//

import UIKit
import SnapKit
import Then

class PlantCustomButton: UIButton {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#fileID, #function, #line, "- ")
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
    }
    
    convenience init(title: String = "no name", bgColor: UIColor = .white, tintColor: UIColor = .blue, cornerRadius: CGFloat = 8){
        self.init(type: .system)
        self.setTitle(title, for: .normal)
        self.backgroundColor = bgColor
        self.tintColor = tintColor
        self.layer.cornerRadius = cornerRadius
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
   
}
