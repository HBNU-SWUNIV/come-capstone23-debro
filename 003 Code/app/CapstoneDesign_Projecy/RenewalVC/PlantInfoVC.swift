//
//  PlantInfoVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/09/06.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import AWSS3
import CocoaMQTT
import CocoaMQTTWebSocket

class PlantInfoVC: UIViewController{
    

    // MARK: - variables
    let validDates: [String] = ["2023-10-01", "2023-10-05", "2023-10-12", "2023-10-20"] // 유효한 날짜 문자열 목록
    //var userName: String?
    var plantName: String?
    var birthDate: String?
    var plant_number: Int?
    var dayDifference: Int = 0
    var TimeInterval: Double = 1.5
    let viewCornerRadius: CGFloat = 10
    
    let accessKey: String = "AKIAZJGVIYOU6JH5ZN4C"
    let newAccessKey: String = "AKIAZJGVIYOUSHEJSS76"
    let secretKey: String = "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"
    let newSecretKey: String = "yNjlUvkeQNzzn8XJV67LqRePSa9uIinbleiLr7Wz"
    let s3BucketName = "capston-bucket"
    let s3ObjectKey = "image_20230907_205731.jpg"
    let utilityKey = "utility-key"
    var fileKey = "plant_image/"
    
    var picFileURL: URL?
    
    weak var delegate: ViewControllerDelegate?
    
    @IBOutlet weak var plantDataView: UIView!
    @IBOutlet weak var plantGraphView: UIView!
    @IBOutlet weak var plantPicView: UIView!
    @IBOutlet weak var plantDatePicView: UIView!
    
    @IBOutlet weak var validDatePickerView: UIPickerView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var dayFromBirthDateLabel: UILabel!
    @IBOutlet weak var datatempLabel: UILabel!
    @IBOutlet weak var dataMoisLabel: UILabel!
    @IBOutlet weak var dataHumiLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        validDatePickerView.delegate = self
        validDatePickerView.dataSource = self
        
        
        print("PlantName: \(plantName!), birthDate: \(birthDate!)")
        setUpAWSS3()
        
        dataRequest()
        setUpUI()
        
        print(#fileID, #function, #line, "- ")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PlantViewController Will be Appeared!")
        
        if checkIfFileURLExists(){
            
            if let savedURL = UserDefaults.standard.url(forKey: "picFilePath") {
                self.picFileURL = savedURL
            }
            
            do {
                //let imageData = try Data(contentsOf: picFileURL)
                guard let unwrappedURL = picFileURL else {
                    print("picFileURL is nil")
                    return
                }
                let imageData = try? Data(contentsOf: unwrappedURL)
                
                guard let unwrappedImageData = imageData else {
                    print("unwrappedImageData is nil")
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: unwrappedImageData)
                    self.plantImageView.image = image
                }
                
            } catch {
                print("Error loading image : \(error)")
            }
        } else {
            requestimage()
        }
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("PlantViewController Appeared!")
        
        print("imageView:\(String(describing: plantImageView.image?.scale))")
        
    }
    
    deinit {
        print("PlantInfoVC has been deinitialized")
    }
    
    
    
    // MARK: - IBAction
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: ContentView())
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        
        // "아니오" 버튼 추가
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // "예" 버튼 추가. 글자색을 빨간색으로 설정하고, 데이터를 삭제하는 로직을 실행합니다.
        let deleteAction = UIAlertAction(title: "예", style: .default) { _ in
            self.dataDelete()
            DispatchQueue.main.asyncAfter(deadline: .now() + self.TimeInterval) {
                self.dismiss(animated: true, completion: nil)
                
            }
            
            
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(deleteAction)
        
        // Alert 컨트롤러 표시
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    // MARK: - function
    
    fileprivate func dataDelete(){
        
        guard let url = generateURL(base: "http://hyunul.com/plant/"+String(plant_number!), queryParameters: [:]) else {
            // url 생성에 실패한 경우에 대한 처리
            return
        }
        
        print(url) 
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 처리할 내용 (예: 응답으로 부터의 데이터 파싱)
            if let data = data {
                // do something with the data
            }
            
            // 데이터 삭제가 성공적으로 완료되었을 때 Alert 띄우기
            DispatchQueue.main.async {
                let confirmationAlert = UIAlertController(title: nil, message: "삭제되었습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    
                    // 일정 시간 후에 메인 스레드에서 작업 수행
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.TimeInterval) {
                        self.delegate?.refreshUIOnViewController()
                        print(#fileID, #function, #line, "- delegate func passed!")
                        //self.dismiss(animated: true, completion: nil)
                    }
                }
                confirmationAlert.addAction(okAction)
                self.present(confirmationAlert, animated: true, completion: nil)
            }

        }

        task.resume()
        
        
    }
    
    fileprivate func generateURL(base: String, queryParameters: [String: String]) -> URL? {
        var components = URLComponents(string: base)
        
        components?.queryItems = queryParameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        return components?.url
    }
    fileprivate func dataRequest(){
        
        //let dateString = "2023-10-01" // 예시 문자열
        let dateFormatter = DateFormatter()
        
        // 문자열을 Date로 변환
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: birthDate!) {
            print("Converted BirthDate:", date)
            
            // 현재 날짜 가져오기
            let currentDate = Date()
            
            // 두 날짜 사이의 차이 계산
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: date, to: currentDate)
            
            // 몇 일 차이가 나는지 출력
            if let dayDifference = components.day {
                print("Difference in days:", dayDifference)
                self.dayDifference = dayDifference
                
            } else {
                print("Could not calculate day difference")
            }
            
        } else {
            print("Invalid date string")
        }
        
        
        let urlString = "http://hyunul.com/sensor/recent"
        
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
                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
                    let baseResponse = try JSONDecoder().decode(BaseData.self, from: jsonData)
                    
                    guard let humidity = baseResponse.data?.humidity else {
                        return
                    }
                    guard let moisture = baseResponse.data?.moisture else {
                        return
                    }
                    guard let temperature = baseResponse.data?.temperature else {
                        return
                    }
                    
                    print("습도: " + humidity)
                    print("수분: " + moisture)
                    print("온도: " + temperature)
                    
                    DispatchQueue.main.async {
                        
                        
                        self.plantNameLabel.text = self.plantName
                        self.dayFromBirthDateLabel.text = "\(self.plantName!)과 함께한지 벌써 \(String(self.dayDifference))일이 지났어요"
                        self.datatempLabel.text = "온도 : " + temperature + "도"
                        self.dataMoisLabel.text = "토양의 습도 :" + moisture
                        self.dataHumiLabel.text = "대기의 습도 :" + humidity
                        
                        //self.requestimage()
                    }
                    
                } catch {
                }
            }
            else{
                DispatchQueue.main.async {
                    //self.requestimage() // dataRequest의 네트워크 작업이 완료된 후 requestImage 호출
                }
            }
            
        }.resume()
        
        
        
        
        
    }
    func upload(){
        
        guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: utilityKey)
        else
        {
            return
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl") //URL로 이미지 읽을 수 있도록 권한 설정 (이 헤더 없으면 못읽음)
        expression.progressBlock = {[weak self] (task, progress) in
            guard let self = self else { return }
            print("progress \(progress.fractionCompleted)")
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { [weak self] (task, error) -> Void in
            guard let self = self else { return }
            print("task finished")
            
            let url = AWSS3.default().configuration.endpoint.url
            let publicURL = url?.appendingPathComponent(self.s3BucketName).appendingPathComponent(self.fileKey)
            if let absoluteString = publicURL?.absoluteString {
                print("image url ↓↓")
                print(absoluteString)
            }
            
            if let query = task.request?.url?.query,
               var removeQueryUrlString = task.request?.url?.absoluteString.replacingOccurrences(of: query, with: "") {
                removeQueryUrlString.removeLast() // 맨 뒤 물음표 삭제
                print("업로드 리퀘스트에서 쿼리만 제거한 url ↓↓") //이 주소도 파일 열림
                print(removeQueryUrlString)
            }
        }
        guard let data = UIImage(named: "img")?.pngData() else { return }
        
        transferUtility.uploadData(data as Data, bucket: s3BucketName, key: fileKey, contentType: "image/png", expression: expression,
                                   completionHandler: completionHandler).continueWith
        {
            [weak self] task -> AnyObject? in
            guard let self = self else { return nil }
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
                
            }
            
            if let _ = task.result {
                print ("upload successful.")
            }
            
            return nil
        }
    }
    
    func setUpUI() {
        plantDataView.layer.cornerRadius = viewCornerRadius
        plantDataView.clipsToBounds = true
        
        plantGraphView.layer.cornerRadius = viewCornerRadius
        plantGraphView.clipsToBounds = true
        
        plantPicView.layer.cornerRadius = viewCornerRadius
        plantPicView.clipsToBounds = true
        
        plantDatePicView.layer.cornerRadius = viewCornerRadius
        plantDatePicView.clipsToBounds = true
    }
    
    
}
extension PlantInfoVC: UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    
    // UIPickerView DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return validDates.count
    }
    
    // UIPickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return validDates[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected date: \(validDates[row])")
        
        // 선택된 날짜를 확인하고 알림을 표시합니다.
        showConfirmationAlert(forDate: validDates[row])
    }
    
    func showConfirmationAlert(forDate date: String) {
        let alertController = UIAlertController(title: "선택 확인", message: "\(date)를 선택했습니다. 계속하시겠습니까?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            // "예" 버튼을 눌렀을 때의 동작을 여기에 작성합니다.
            self?.presentNextViewController(date)
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentNextViewController(_ selectedDate: String) {
        // 다음 UIViewController의 인스턴스를 생성하고 표시합니다.
        //        let nextViewController = NextViewController() // NextViewController는 당신이 표시하려는 다음 뷰 컨트롤러의 클래스입니다.
        //        self.present(nextViewController, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondViewController = storyboard.instantiateViewController(identifier: "PlantPic_VC") as? PlantPicVC else {
            print("Could not instantiate view controller with identifier of type PlantPicVC")
            return
        }
        
        secondViewController.selectedDate = selectedDate
        secondViewController.plant_number = plant_number!
        secondViewController.plantName = plantName!
        
        secondViewController.modalPresentationStyle = .fullScreen  // 화면을 꽉 채우기
        
        // 뷰 컨트롤러 present
        self.present(secondViewController, animated: true, completion: nil)
    }
    func requestimage(){
        
        
        if let savedURL = UserDefaults.standard.url(forKey: "picFileURL") {
            self.picFileURL = savedURL
        }
        
        print("requestimage func worked!!")
        print("S3 bucket: \(self.s3BucketName)")
        print("fileKey: \(self.fileKey)")
        

        
        guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: utilityKey)
        else
        {
            return
        }
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {[weak self] (task, progress) in
            guard let self = self else { return }
            print("progress \(progress.fractionCompleted)") // 다운로드 진행 상황 출력
            
            DispatchQueue.main.async {
                // 여기에 UI 업데이트 로직 추가, 예를 들면, 진행 표시줄(progress bar) 업데이트
            }
            
            if progress.fractionCompleted == 1.0 {
                print("Download complete!") // 다운로드 완료 메시지 출력
            }
        }
        
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { [weak self] (task, url, data, err) -> Void in       // 여기
            // Check if there is an error
            if let error = err {
                print("Detailed Download Error: \(error)")
                print("Download Error: \(error.localizedDescription)")
            } else {
                // No error, download completed successfully
                print("Download task finished successfully")
                
                
                DispatchQueue.main.async { [weak self] in
                    if let imagedata = data {
                        print("Image data exists with size: \(imagedata.count) bytes")
                        
                        //데이터를 파일로 저장하여 직접 확인
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        
                        let fileURL = documentsURL.appendingPathComponent("test_image.jpg")
                        
                        self?.picFileURL = fileURL
                        UserDefaults.standard.set(fileURL, forKey: "picFilePath")
                        
                        print("File saved at: \(fileURL.absoluteString)")
                        try? imagedata.write(to: fileURL)
                        print("Image data written to \(fileURL)")
                        
                        if let image = UIImage(data: imagedata) {
                            self?.plantImageView.image = image
                        } else {
                            print("Could not create image from data!")
                        }
                    } else {
                        print("Image data is nil!")
                    }
                }
            }
        }
        
        print("progressBlock before download: \(String(describing: expression.progressBlock))")
        print("completionHandler before download: \(String(describing: completionHandler))")
        
        transferUtility.downloadData(fromBucket: s3BucketName, key: fileKey, expression: expression, completionHandler: completionHandler).continueWith()
        {
            [weak self] task -> AnyObject? in
            guard let self = self else { return nil }
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let _ = task.result {
                print ("download successful.")
                
            }
            return nil
        }
        print("progressBlock after download: \(String(describing: expression.progressBlock))")
        print("completionHandler after download: \(String(describing: completionHandler))")
        
    }
    
    func checkIfFileURLExists() -> Bool {
        if let savedPath = UserDefaults.standard.string(forKey: "picFilePath") {
            self.picFileURL = URL(fileURLWithPath: savedPath)
            print("FileURL Exist! : \(String(describing: self.picFileURL?.absoluteString))")
            return true
        } else {
            print("FileURL doesn't Exist!")
            return false
        }
    }
    
    func setUpAWSS3(){
        // aws s3 설정
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: newAccessKey, secretKey: newSecretKey)
        
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let tuConf = AWSS3TransferUtilityConfiguration()
        tuConf.isAccelerateModeEnabled = false
        
        //AWSS3TransferUtility.unregisterS3TransferUtility(forKey: utilityKey)
        
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: utilityKey
        )
        //print("ViewController viewDidLoad")
        print("AWSS3TransferUtility instance: \(AWSS3TransferUtility.default())")
        
        //        let dateFormat = DateFormatter()
        //        dateFormat.dateFormat = "yyyyMMdd/"
        //        fileKey += dateFormat.string(from: Date())
        //        fileKey += String(Int64(Date().timeIntervalSince1970)) + "_"
        //        fileKey += UUID().uuidString + ".png"
        fileKey += "image_20230907_205731.jpg"
        
        print(fileKey)
    }
}


