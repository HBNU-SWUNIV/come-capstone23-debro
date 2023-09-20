//
//  ViewController.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/05/11.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    @StateObject var infoVM: InfoVM = InfoVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(#function)
        if segue.identifier == "toCameraVC" {
            let CameraVC = segue.destination as! CameraVC
            // let thirdVC = segue.destination as! ThirdViewController
        }
        
        if segue.identifier == "toGivewaterVC" {
            let GivewaterVC = segue.destination as! GivewaterVC
        }
        if segue.identifier == "toSensorMonitoringVC"{
            let SensorMonitoringVC = segue.destination as! SensorMonitoringVC
        }
        
        if segue.identifier == "toChartVC"{
            let ChartVC = segue.destination as! ChartVC
        }
        
        
        
        
    }
    
   
    
    
    

}









#if DEBUG

import SwiftUI

struct ViewControllerPresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        ViewController()
    }
    
    
}
struct ViewcontrollerPresentable_PreviewProvider : PreviewProvider {
    static var previews: some View {
        ViewControllerPresentable()
    }
}

#endif
