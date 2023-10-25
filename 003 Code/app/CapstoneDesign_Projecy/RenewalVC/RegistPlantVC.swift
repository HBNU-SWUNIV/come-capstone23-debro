//
//  RegistPlantVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/09/06.
//

import UIKit
import SnapKit
import Then
import MapKit
import CoreLocation

class RegistPlantVC: UIViewController, UITextFieldDelegate {
    
    
    // MARK: - Variables
    
    var userName: String = "Jonghun Kim"
    var plant_number: Int = 0
    var viewRadius: CGFloat = 15
    var TimeInterval: Double = 1.5
    
    // address = https://geniewiz.github.io/kakao-postcode/
    // MARK: - Properties
    
    weak var delegate: ViewControllerDelegate?
    
    @IBOutlet weak var plantNameView: UIView!
    @IBOutlet weak var checkOutsideView: UIView!
    @IBOutlet weak var selectPlantTypeView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    @IBOutlet weak var addPlantbutton: UIButton!
    
    
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    
    @IBOutlet weak var outsideCheckSwitch: UISwitch!
    
    
    var items: [UIAction] {
        
        let kidneyBean = UIAction(
            title: "강낭콩",
            //image: UIImage(systemName: "plus"),
            handler: { [unowned self] _ in
                //self..text = "Save"
            })
        
        let Catus = UIAction(
            title: "선인장",
            //image: UIImage(systemName: "trash"),
            handler: { [unowned self] _ in
                //self.label.text = "Delete"
            })
        
        let Items = [ kidneyBean, Catus]
        
        return Items
    }
    
    
    @IBOutlet weak var menuButton: UIButton!
    
    //@IBOutlet weak var plantmenu: UIMenu!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        plantNameTextField.delegate = self
        addressTextField.delegate = self
        
        setUpMenus()
        setUpUI()
        
        checkTextFieldsAndUpdateButton()
    }
    
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        print(addressTextField.text ?? "몰?")
        
        self.dismiss(animated: true)
    }
    
    
    
    
    @IBAction func addPlantButtonTapped(_ sender: UIButton) {
        
        
        //print(plantmenu.selectedElements.first?.title ?? "몰?루") // -> 안됨
        print(menuButton.menu?.selectedElements.first?.title ?? "몰?루") // -> 됨
        
        // 타이틀을 서버로 보내고자 한다고 가정합니다.
        if let title = menuButton.menu?.selectedElements.first?.title {
            //sendPostRequest(with: title)
        }
        // Post 관련 로직 추가할 것
        // Post 로직 처리 후 MainVC 리프레쉬 로직 추가할 것
        
        sendPostRequest()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.TimeInterval) {
            self.delegate?.refreshUIOnViewController()
            self.dismiss(animated: true)
        }
        
    }
    
    func sendPostRequest() {
        // 이것이 서버 URL이라고 가정합니다.
        let url = URL(string: "http://hyunul.com/plant")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 필요한 데이터 가져오기
        let plantNumber = plant_number
        let plantName = plantNameTextField.text ?? ""
        let address = addressTextField.text ?? ""
        let isOutside = outsideCheckSwitch.isOn
        let selectedTitle = menuButton.menu?.selectedElements.first?.title ?? ""
        let ownerName = userName
        
        print(#fileID, #function, #line, "- Body --- plantNumber: \(plantNumber), plantName\(plantName)address\(address)isOutside\(String(isOutside))selectedTitle\(selectedTitle)")
        
        // Body 딕셔너리 생성 [Key : value]
        let body: [String: Any] = [
            "userName": ownerName, // String
            "plantNumber": plantNumber, // Int
            "plantName": plantName, // Stirng
            "address": address, // Stirng
            "isOutside": isOutside, // Bool
            "selectedTitle": selectedTitle // Stirng - 식물 종류
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("데이터 직렬화 오류: \(error)")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("POST 요청 오류: \(error)")
                self.displayAlert(with: "오류", message: "POST 요청을 보내는 데 실패했습니다: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // 필요에 따라 응답 데이터를 처리하십시오.
                    print("POST 요청이 성공했습니다!")
                } else {
                    print("서버가 응답 상태 코드로 응답했습니다: \(httpResponse.statusCode)")
                    self.displayAlert(with: "오류", message: "서버가 응답 상태 코드로 응답했습니다: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
        
        
        
        
        //self.dismiss(animated: true)
    }
    
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        
        print(menuButton.menu?.children.first?.title ?? "낫띵")
        
        print(menuButton.menu?.selectedElements.first?.title ?? "낫띵")
    }
    
    
    
    // MARK: - Funtion
    
    func setUpMenus(){
        let menu = UIMenu(title: "식물의 종류",
                          children: items)
        menuButton.menu = menu
    }
    func setUpUI(){
        plantNameView.layer.cornerRadius = viewRadius
        plantNameView.clipsToBounds = true
        
        checkOutsideView.layer.cornerRadius = viewRadius
        checkOutsideView.clipsToBounds = true
        
        selectPlantTypeView.layer.cornerRadius = viewRadius
        selectPlantTypeView.clipsToBounds = true
        
        addressView.layer.cornerRadius = viewRadius
        addressView.clipsToBounds = true
        
        addPlantbutton.layer.cornerRadius = viewRadius
        addPlantbutton.clipsToBounds = true
        
        //addPlantbutton.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTextField))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func displayAlert(with title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func handleTapOutsideTextField() {
        view.endEditing(true)  // 모든 활성화된 편집 종료
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if textField == plantNameTextField {
            // 첫 번째 텍스트 필드에 대한 로직
            
            
            return true
        } else if textField == addressTextField {
            // 두 번째 텍스트 필드에 대한 로직
            // 예를 들어, YourPopupViewController라는 뷰 컨트롤러를 present하려면:
            let popupVC = KakaoAddressVC()
            self.present(popupVC, animated: true, completion: nil)
            
            
            
            return false  // 이것은 textField의 편집을 방지하며, 원하면 true로 변경 가능
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            
            textField.placeholder = "텍스트를 입력해주세요!"
            return false  // 빈 텍스트를 허용하지 않습니다.
        }
        return true
    }
    
    func checkTextFieldsAndUpdateButton() {
        if let text1 = plantNameTextField.text, let text2 = addressTextField.text, !text1.trimmingCharacters(in: .whitespaces).isEmpty, !text2.trimmingCharacters(in: .whitespaces).isEmpty {
                addPlantbutton.isEnabled = true
            } else {
                addPlantbutton.isEnabled = false
            }
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextFieldsAndUpdateButton()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 이 메소드는 텍스트 변경 직후에 호출되므로, 실제 변경을 반영하기 위해 DispatchQueue를 사용
        DispatchQueue.main.async {
            self.checkTextFieldsAndUpdateButton()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // 키보드 숨김.
        return true
    }
    

    
}

