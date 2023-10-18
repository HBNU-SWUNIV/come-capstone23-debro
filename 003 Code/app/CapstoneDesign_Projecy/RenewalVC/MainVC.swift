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
    
    var userName: String = "Jonghun Kim"
    var isExist1: Bool = false
    var isExist2: Bool = false
    var isExist3: Bool = false
    var isExist4: Bool = false
    
    var plant1_name: String = ""
    var plant2_name: String = ""
    var plant3_name: String = ""
    var plant4_name: String = ""
    
    var plant1_birthDate: String = ""
    var plant2_birthDate: String = ""
    var plant3_birthDate: String = ""
    var plant4_birthDate: String = ""
    
    var weatherStr: String = ""
    
    let btnRadiuds: CGFloat = 15
    let viewCornerRadius: CGFloat = 10
    
    let btnColor: UIColor = #colorLiteral(red: 0.8941176471, green: 1, blue: 0.8588235294, alpha: 1)
    
    let fakeURL: String = "http://localhost:3000/PlantExist"
    let realURL: String = "http://hyunul.com/plant"
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tempDataLabel: UILabel!
    @IBOutlet weak var humiDataLabel: UILabel!
    @IBOutlet weak var rainfallDataLabel: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var buttonEmbedView: UIView!
    @IBOutlet weak var weatherView: UIView!
    
    
    @IBOutlet weak var plant1_Button: UIButton!
    @IBOutlet weak var plant2_Button: UIButton!
    @IBOutlet weak var plant3_Button: UIButton!
    @IBOutlet weak var plant4_Button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //데이터 요청 및 파싱
        dataRequest()
        
        // UI 셋업
        //setupUI()
        
        
    }
    
    fileprivate func setupUI(){
        
        setupViewUI()
        setupButtonUI()
        setupUserName()
        
        setUpButtonAction(plant1_Button, isExist1)
        setUpButtonAction(plant2_Button, isExist2)
        setUpButtonAction(plant3_Button, isExist3)
        setUpButtonAction(plant4_Button, isExist4)
        
    }
    fileprivate func setupViewUI(){
        
        buttonEmbedView.layer.cornerRadius = viewCornerRadius
        buttonEmbedView.clipsToBounds = true
        
        weatherView.layer.cornerRadius = viewCornerRadius
        weatherView.clipsToBounds = true
    }
    fileprivate func setupButtonUI(){
        
        print(#fileID, #function, #line, "- ")
        
        plant1_Button.layer.cornerRadius = btnRadiuds
        plant1_Button.clipsToBounds = true
        
        plant2_Button.layer.cornerRadius = btnRadiuds
        plant2_Button.clipsToBounds = true
        
        plant3_Button.layer.cornerRadius = btnRadiuds
        plant3_Button.clipsToBounds = true
        
        plant4_Button.layer.cornerRadius = btnRadiuds
        plant4_Button.clipsToBounds = true
        
        
        
        
        //있을경우 없을경우 UI구성 달리할 코드 짜기
        
        if isExist1 == true {
            plant1_Button.backgroundColor = .systemGreen
            plant1_Button.setTitle(plant1_name, for: .normal)
            plant1_Button.setTitleColor(.white, for: .normal)
        } else {
            plant1_Button.backgroundColor = btnColor
            plant1_Button.setTitle("식물 추가...", for: .normal)
            plant1_Button.setTitleColor(.systemGreen, for: .normal)
        }
        
        if isExist2 == true {
            plant2_Button.backgroundColor = .systemGreen
            plant2_Button.setTitle(plant2_name, for: .normal)
            plant2_Button.setTitleColor(.white, for: .normal)
            
        } else {
            plant2_Button.backgroundColor = btnColor
            plant2_Button.setTitle("식물 추가...", for: .normal)
            plant2_Button.setTitleColor(.systemGreen, for: .normal)
        }
        
        if isExist3 == true {
            plant3_Button.backgroundColor = .systemGreen
            plant3_Button.setTitle(plant3_name, for: .normal)
            plant3_Button.setTitleColor(.white, for: .normal)
            
        } else {
            plant3_Button.backgroundColor = btnColor
            plant3_Button.setTitle("식물 추가...", for: .normal)
            plant3_Button.setTitleColor(.systemGreen, for: .normal)
        }
        
        if isExist4 == true {
            plant4_Button.backgroundColor = .systemGreen
            plant4_Button.setTitle(plant4_name, for: .normal)
            plant4_Button.setTitleColor(.white, for: .normal)
        } else {
            plant4_Button.backgroundColor = btnColor
            plant4_Button.setTitle("식물 추가...", for: .normal)
            plant4_Button.setTitleColor(.systemGreen, for: .normal)
        }
        
        plant1_Button.tag = 1
        plant2_Button.tag = 2
        plant3_Button.tag = 3
        plant4_Button.tag = 4
        
        
    }
    fileprivate func setupUserName(){
        userNameLabel.text = userName + " 님"
    }
    fileprivate func setUpButtonAction(_ button: UIButton, _ value: Bool){
        
        if value == true {
            button.addTarget(self, action: #selector(detailPlant), for: .touchUpInside)
        }
        else {
            button.addTarget(self, action: #selector(registPlant), for: .touchUpInside)
        }
        
        
    }
    fileprivate func dataRequest(){
        //let urlString = fakeURL // 이후 realURL 변경
        let urlString = realURL
        
        guard let url = URL(string: urlString) else {
            return //completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            
            
            print("data: \(data)")
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response data string: \(responseString)")
            }
            print("urlResponse: \(urlResponse)")
            print("err: \(err)")
            
            
            if let error = err {
                return //completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return //completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return //completion(.failure(ApiError.unauthorized))
            case 204:
                return //completion(.failure(ApiError.noContent))
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                return //completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    let plantDatas = try JSONDecoder().decode(PlantDatas.self, from: jsonData)
                    if let plantDataArray = plantDatas.data {
                        
                        print(#fileID, #function, #line, "- plantDataArray.count == \(plantDataArray.count)")
   
                        
                        
                        if plantDataArray.count > 0 {
                            self.isExist1 = true
                            self.plant1_name = plantDataArray[0].plantName ?? ""
                            self.plant1_birthDate = plantDataArray[0].time ?? ""
                            
                        }
                        
                        if plantDataArray.count > 1 {
                            self.isExist2 = true
                            self.plant2_name = plantDataArray[1].plantName ?? ""
                            self.plant2_birthDate = plantDataArray[1].time ?? ""
                            
                        }
                        
                        if plantDataArray.count > 2 {
                            self.isExist3 = true
                            self.plant3_name = plantDataArray[2].plantName ?? ""
                            self.plant3_birthDate = plantDataArray[2].time ?? ""
                            
                        }
                        
                        if plantDataArray.count > 3 {
                            self.isExist4 = true
                            self.plant4_name = plantDataArray[3].plantName ?? ""
                            self.plant4_birthDate = plantDataArray[3].time ?? ""
                            
                        }
                    }
                    
                    print(#fileID, #function, #line, "- isExist1 = \(self.isExist1), isExist2 = \(self.isExist2), isExist3 = \(self.isExist3), isExist4 = \(self.isExist4)")
                    
                    DispatchQueue.main.async {
                        // UI 업데이트
                        self.setupUI() // UI를 업데이트하는 함수 호출
                    }
                } catch {
                    print("decode error occured!\(error)")
                }
            }
            
            
            
        }.resume()
        
    }
    // MARK: - 날씨 이미지 교체
    fileprivate func selectWeather(_ weatherStr: String){
        
        
        
        switch weatherStr {
        case "sunny":
            weatherImageView.image = UIImage(systemName: "sun.max")
            
            // case 추가
            
        default:
            break
            
        }
        
    }
    
    @objc func detailPlant(_ sender: UIButton) {
        print("detailPlant!")
        
        // 스토리보드에서 뷰 컨트롤러 로드
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "PlantInfo_VC") as? PlantInfoVC else {
            print("Could not instantiate view controller with identifier of type PlantInfoVC")
            return
        }
        
        switch sender.tag {
        case 1:
            secondViewController.plantName = self.plant1_name
            secondViewController.birthDate = self.plant1_birthDate
            secondViewController.plant_number = sender.tag
            secondViewController.delegate = self
        case 2:
            secondViewController.plantName = self.plant2_name
            secondViewController.birthDate = self.plant2_birthDate
            secondViewController.plant_number = sender.tag
            secondViewController.delegate = self
        case 3:
            secondViewController.plantName = self.plant3_name
            secondViewController.birthDate = self.plant3_birthDate
            secondViewController.plant_number = sender.tag
            secondViewController.delegate = self
        case 4:
            secondViewController.plantName = self.plant4_name
            secondViewController.birthDate = self.plant4_birthDate
            secondViewController.plant_number = sender.tag
            secondViewController.delegate = self
            
        default:
            break
        }
        
        secondViewController.modalPresentationStyle = .fullScreen  // 화면을 꽉 채우기
        
        // 뷰 컨트롤러 present
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    @objc func registPlant(_ sender: UIButton) {
        print("addPlant!")
        
        // 알림 생성
        let alert = UIAlertController(title: nil, message: "식물을 추가하시겠습니까?", preferredStyle: .alert)
        
        // '예' 액션 추가
        alert.addAction(UIAlertAction(title: "예", style: .default, handler: { action in
            // '예' 버튼이 눌렸을 때 실행할 코드
            self.addPlant(sender)
        }))
        
        // '아니오' 액션 추가
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
        
        // 알림 표시
        self.present(alert, animated: true, completion: nil)
    }
    
    func addPlant(_ sender: UIButton) {
        // 식물 추가 코드
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "RegistPlant_VC") as? RegistPlantVC else {
            print("Could not instantiate view controller with identifier of type RegistPlantVC")
            return
        }
        
        switch sender.tag {
        case 1:
            secondViewController.plant_number = sender.tag
        case 2:
            secondViewController.plant_number = sender.tag
        case 3:
            secondViewController.plant_number = sender.tag
        case 4:
            secondViewController.plant_number = sender.tag
            
        default:
            break
        }
        
        secondViewController.delegate = self
        
        secondViewController.modalPresentationStyle = .fullScreen  // 화면을 꽉 채우기
        
        // 뷰 컨트롤러 present
        self.present(secondViewController, animated: true, completion: nil)
        
        print("Plant Added!")
    }
    
    
}
extension MainVC: ViewControllerDelegate {
    func refreshUIOnViewController() {
        
        removeAllTarget()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print(#fileID, #function, #line, "- almost state datarequst on MainVC")
            self.dataRequest()
        }
        //dataRequest()
    }
    
    func removeAllTarget(){
        
        self.isExist1 = false
        self.isExist2 = false
        self.isExist3 = false
        self.isExist4 = false
        
        plant1_Button.removeTarget(nil, action: nil, for: .allEvents)
        plant2_Button.removeTarget(nil, action: nil, for: .allEvents)
        plant3_Button.removeTarget(nil, action: nil, for: .allEvents)
        plant4_Button.removeTarget(nil, action: nil, for: .allEvents)
    }
}

