//
//  MainVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/09/06.
//

import UIKit
import SnapKit
import Then

class MainVC: UIViewController {
    
    let btnRadiuds: CGFloat = 15
    
    
    @IBOutlet weak var plant1_Button: UIButton!
    @IBOutlet weak var plant2_Button: UIButton!
    @IBOutlet weak var plant3_Button: UIButton!
    @IBOutlet weak var plant4_Button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    fileprivate func setupUI(){
        print(#fileID, #function, #line, "- ")
        
        plant1_Button.layer.cornerRadius = btnRadiuds
        plant1_Button.clipsToBounds = true
        
        plant2_Button.layer.cornerRadius = btnRadiuds
        plant2_Button.clipsToBounds = true
        
        plant3_Button.layer.cornerRadius = btnRadiuds
        plant3_Button.clipsToBounds = true
        
        plant4_Button.layer.cornerRadius = btnRadiuds
        plant4_Button.clipsToBounds = true
        
        
    }
    
}
