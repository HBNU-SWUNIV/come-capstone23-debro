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

class PlantInfoVC: UIViewController, ViewControllerDelegate_completion{
    
    
    
    
    // MARK: - variables
    //let validDates: [String] = ["2023-10-01", "2023-10-05", "2023-10-12", "2023-10-20"] // 유효한 날짜 문자열 목록
    var validDates: [String] = []
    var validDates_pickerData: [String] = []
    //var userName: String?
    var plantName: String?
    var birthDate: String?
    var fileName: String?
    var plant_number: Int?
    var dayDifference: Int = 0
    var TimeInterval: Double = 1.5
    let viewCornerRadius: CGFloat = 10
    let btnCornerRadius: CGFloat = 5
    
    let accessKey: String = "AKIAZJGVIYOU6JH5ZN4C"
    
    let secretKey: String = "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"
    
    let newAccessKey: String = "AKIAZJGVIYOUSHEJSS76"
    let newSecretKey: String = "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"
    
    let realstrURL: String = "http://hyunul.com/"
    
    
    let s3BucketName = "capston-bucket"
    let s3ObjectKey = "image_20230907_205731.jpg"
    let utilityKey = "utility-key" + String(arc4random())
    var fileKey = "plant_image/"
    var filelistkey = "plant_image/"
    
    var currentDateString: String = ""
    var recentFileKey: String = ""
    
    var picFileURL: URL?
    
    weak var delegate: ViewControllerDelegate?
    
    @IBOutlet weak var plantDataView: UIView!
    @IBOutlet weak var plantGraphView: UIView!
    @IBOutlet weak var plantPicView: UIView!
    @IBOutlet weak var plantDatePicView: UIView!
    
    @IBOutlet weak var giveWaterView: UIView!
    
    
    
    @IBOutlet weak var validDatePickerView: UIPickerView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var dayFromBirthDateLabel: UILabel!
    @IBOutlet weak var datatempLabel: UILabel!
    @IBOutlet weak var dataMoisLabel: UILabel!
    @IBOutlet weak var dataHumiLabel: UILabel!
    
    @IBOutlet weak var giveWaterLabel: UILabel!
    
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBOutlet weak var giveWaterButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        validDatePickerView.delegate = self
        validDatePickerView.dataSource = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        currentDateString = dateFormatter.string(from: Date())

        recentFileKey = "recentFileKey" + currentDateString
        
        
        self.getImageList {
            self.extractDate() // extractDate를 먼저 호출
            self.setUpAWSS3() // 그 다음 setUpAWSS3 호출

            DispatchQueue.main.async { // UI 관련 코드는 메인 스레드에서 실행
                self.dataRequest()
                self.setUpUI()
                self.requestimage()
            }
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PlantViewController Will be Appeared!")
        
        //insertImage() // 이후 requestimage() 실행
        
        //requestimage()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("PlantViewController Appeared!")
        
        
        //print("imageView:\(String(describing: plantImageView.image?.scale))")
        
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
    
    
    @IBAction func giveWaterButtonTapped(_ sender: UIButton) {
        
        print(#fileID, #function, #line, "- giveWaterButtonTapped!")
        
        giveWaterRequest()
    }
    
    
    // MARK: - function
    
    func insertImage(){
        if checkIfFileURLValids(){
            

            
            if let savedURL = UserDefaults.standard.url(forKey: recentFileKey) {
                self.picFileURL = savedURL
                print(#fileID, #function, #line, "- savedURL - \(savedURL)")
            }
            
//            if let savedURL = UserDefaults.standard.url(forKey: recentFileKey) {
//                self.picFileURL = savedURL
//                print(#fileID, #function, #line, "- savedURL - \(savedURL)")
//            }
            
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
            print(#fileID, #function, #line, "- checkIfFileURLValids else block")
            requestimage()
        }
        
        
    }
    
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
                    
                    print("습도: " + humidity + " %")
                    print("토양 수분함량: " + moisture + " %")
                    print("온도: " + temperature + " °C")
                    
                    DispatchQueue.main.async {
                        
                        
                        //                        self.plantNameLabel.text = self.plantName
                        //                        self.dayFromBirthDateLabel.text = "\(self.plantName!)과 함께한지 벌써 \(String(self.dayDifference))일이 지났어요"
                        //                        self.giveWaterLabel.text = "\(self.plantName!)에게 물을 줄 수 있어요"
                        self.datatempLabel.text = "온도: " + temperature + " °C"
                        self.dataMoisLabel.text = "토양 수분함량: " + moisture + " %"
                        self.dataHumiLabel.text = "습도: " + humidity + " %"
                        
                        
                    }
                    
                } catch {
                }
            }
            else{
                DispatchQueue.main.async {
                    
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
    
    fileprivate func getImageList(completion: @escaping () -> Void){
        guard let url = URL(string: realstrURL + "s3") else {
            print("Invalid URL")
            return
        }
        print("\(realstrURL)s3")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP Error: \(response ?? URLResponse())")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(ImageList.self, from: data)
                DispatchQueue.main.async {
                    self?.validDates = decodedData
                    completion()
                    self?.extractDate()
                    self?.validDatePickerView.reloadAllComponents()
                    
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        task.resume()
        
        
    }
    
    fileprivate func extractDate(){
        
        print(#fileID, #function, #line, "- validDates \(validDates)")
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd_HHmmss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yy.MM.dd_HH시mm분ss초"
        //outputFormatter.dateFormat = "MM월 dd일 HH시 mm분 ss초"
        
        for dateString in validDates {
            // "plant_image/image_" 부분과 ".jpg"를 제거합니다.
            let trimmedString = dateString.replacingOccurrences(of: "plant_image/image_", with: "").replacingOccurrences(of: ".jpg", with: "")
            
            // 문자열을 Date 객체로 변환합니다.
            if let date = inputFormatter.date(from: trimmedString) {
                // Date 객체를 원하는 형식의 문자열로 변환하여 배열에 추가합니다.
                let formattedString = outputFormatter.string(from: date)
                validDates_pickerData.append(formattedString)
            } else {
                print("Invalid date format: \(trimmedString)")
            }
        }
        
        print(#fileID, #function, #line, "- validDates_pickerData \(validDates_pickerData)")
        
        
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
        
        giveWaterView.layer.cornerRadius = viewCornerRadius
        giveWaterView.clipsToBounds = true
        
        giveWaterButton.layer.cornerRadius = btnCornerRadius
        giveWaterButton.clipsToBounds = true
        
        deleteButton.layer.cornerRadius = btnCornerRadius
        deleteButton.clipsToBounds = true
        
        
        self.plantNameLabel.text = self.plantName
        self.dayFromBirthDateLabel.text = "\(self.plantName!)과 함께한지 벌써 \(String(self.dayDifference))일이 지났어요"
        self.giveWaterLabel.text = "\(self.plantName!)에게 물을 줄 수 있어요"
        
        DispatchQueue.main.async {
            
            
            
            
            
        }
        
    }
    
    
}
extension PlantInfoVC: UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    
    // UIPickerView DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return validDates_pickerData.count
    }
    
    // UIPickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return validDates_pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected date: \(validDates_pickerData[row])")
        
        // 선택된 날짜를 확인하고 알림을 표시합니다.
        showConfirmationAlert(forDate: validDates_pickerData[row])
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
        secondViewController.delegate = self
        
        secondViewController.modalPresentationStyle = .fullScreen  // 화면을 꽉 채우기
        
        // 뷰 컨트롤러 present
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    
    func requestimage(){
        
        var fileURL: URL? = nil
        
        
        if let savedURL = UserDefaults.standard.url(forKey: recentFileKey) {
            self.picFileURL = savedURL
            print(#fileID, #function, #line, "- savedURL - \(savedURL)")
        }
        
        //        if let savedURL = UserDefaults.standard.url(forKey: "picFileURL") {
        //            self.picFileURL = savedURL
        //            print(#fileID, #function, #line, "- savedURL - \(savedURL)")
        //        }
        
        print(#fileID, #function, #line, "requestimage func worked!!")
        print(#fileID, #function, #line, "S3 bucket: \(self.s3BucketName)")
        print(#fileID, #function, #line, "fileKey: \(self.fileKey)")
        
        
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
                        
                        //let fileURL = documentsURL.appendingPathComponent("test_image.jpg")
                        
                        if let lastValidDate = self?.validDates.last {
                            let sanitizedFileName = lastValidDate.replacingOccurrences(of: "plant_image/", with: "")
                            print(#fileID, #function, #line, "- sanitizedFileName \(sanitizedFileName)")
                            fileURL = documentsURL.appendingPathComponent(sanitizedFileName)
                            self?.picFileURL = fileURL
                        } else {
                            print("There is no last element in validDates array")
                        }
                        
                        if let fileURL = fileURL {
                            UserDefaults.standard.set(fileURL, forKey: self!.recentFileKey)
                            print("File saved at: \(fileURL.absoluteString)")
                            try? imagedata.write(to: fileURL)
                            print("Image data written to \(fileURL)")
                        } else {
                            print("File URL is nil")
                        }
                        
                        
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
    
    func checkIfFileURLValids() -> Bool {
        
        if let savedPath = UserDefaults.standard.string(forKey: recentFileKey) {
            self.picFileURL = URL(fileURLWithPath: savedPath)
            print(#fileID, #function, #line, "FileURL Exist! : \(String(describing: self.picFileURL?.absoluteString))")
            
            
            //return false
            return true
        } else {
            print(#fileID, #function, #line, "- FileURL doesn't Exist!")
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
        
        print("AWSS3TransferUtility instance: \(AWSS3TransferUtility.default())")
        
        
        print(validDates.last ?? "There's Nothing")
        fileKey += validDates.last?.replacingOccurrences(of: "plant_image/", with: "") ?? "image_20230907_205731.jpg"
        fileName = validDates.last?.replacingOccurrences(of: "plant_image/", with: "") ?? "image_20230907_205731.jpg"
        
        print(#fileID, #function, #line, "- validDates.count\(validDates.count)")
        print(#fileID, #function, #line, "- validDates.last \(validDates.last)")
        print(#fileID, #function, #line, "- fileKey \(fileKey)")
        
        
        
        
    }
    func refreshUIOnViewController(completion: @escaping () -> Void) {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        currentDateString = dateFormatter.string(from: Date())

        recentFileKey = "recentFileKey" + currentDateString
        DispatchQueue.global().async {
            self.getImageList {
                self.setUpAWSS3()
            }
            
            self.dataRequest()
            self.setUpUI()
            DispatchQueue.main.async {
                completion()
                self.insertImage()
            }
        }
    }
    
    
    
}
extension PlantInfoVC: CocoaMQTTDelegate, CocoaMQTT5Delegate{
    // self signed delegate
    func mqttUrlSession(_ mqtt: CocoaMQTT, didReceiveTrust trust: SecTrust, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            
            let certData = Data(base64Encoded: myCert as String)!
            
            if let trust = challenge.protectionSpace.serverTrust,
               let cert = SecCertificateCreateWithData(nil,  certData as CFData) {
                let certs = [cert]
                SecTrustSetAnchorCertificates(trust, certs as CFArray)
                
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        
    }
    
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        
        if ack == .accept {
            mqtt.subscribe("debro/camera", qos: CocoaMQTTQoS.qos1)
            //            let chatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
            //            chatViewController?.mqtt = mqtt
            //            chatViewController?.mqttVersion = mqttVesion
            //            navigationController!.pushViewController(chatViewController!, animated: true)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")
        
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic, "id": id])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        TRACE("subscribed: \(success), failed: \(failed)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        print("disconnect res : \(reasonCode)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        print("auth res : \(reasonCode)")
    }
    
    // Optional ssl CocoaMQTT5Delegate
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        /// Validate the server certificate
        ///
        /// Some custom validation...
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        completionHandler(true)
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        TRACE("ack: \(ack)")
        
        if ack == .success {
            if(connAckData != nil){
                print("properties maximumPacketSize: \(String(describing: connAckData!.maximumPacketSize))")
                print("properties topicAliasMaximum: \(String(describing: connAckData!.topicAliasMaximum))")
            }
            
            mqtt5.subscribe("debro/camera", qos: CocoaMQTTQoS.qos1)
            
            
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
        if state == .disconnected {
            
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        TRACE("message: \(message.description), id: \(id)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        TRACE("id: \(id)")
        if(pubAckData != nil){
            print("pubAckData reasonCode: \(String(describing: pubAckData!.reasonCode))")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        TRACE("id: \(id)")
        if(pubRecData != nil){
            print("pubRecData reasonCode: \(String(describing: pubRecData!.reasonCode))")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishComplete id: UInt16,  pubCompData: MqttDecodePubComp?){
        TRACE("id: \(id)")
        if(pubCompData != nil){
            print("pubCompData reasonCode: \(String(describing: pubCompData!.reasonCode))")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?){
        if(publishData != nil){
            print("publish.contentType \(String(describing: publishData!.contentType))")
        }
        
        TRACE("message: \(message.string.description), id: \(id)")
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification")
        
        NotificationCenter.default.post(name: name, object: self, userInfo: ["message": message.string!, "topic": message.topic, "id": id])
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        TRACE("subscribed: \(success), failed: \(failed)")
        if(subAckData != nil){
            print("subAckData.reasonCodes \(String(describing: subAckData!.reasonCodes))")
        }
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], unsubAckData: MqttDecodeUnsubAck?) {
        TRACE("topic: \(topics)")
        if(unsubAckData != nil){
            print("unsubAckData.reasonCodes \(String(describing: unsubAckData!.reasonCodes))")
        }
        print("----------------------")
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        TRACE()
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        TRACE()
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: Error?) {
        TRACE("\(err.description)")
        let name = NSNotification.Name(rawValue: "MQTTMessageNotificationDisconnect")
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func giveWaterRequest() {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let clientID = "CocoaMQTT5-" + String(ProcessInfo().processIdentifier)
        let mqtt5 = CocoaMQTT5(clientID: clientID, host: "58.233.72.16", port: 2883)
        mqtt5.logLevel = .debug
        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
        
        mqtt5.connectProperties = connectProperties
        mqtt5.username = "Mac Test"
        mqtt5.password = "Test1"
        
        let lastWillMessage = CocoaMQTT5Message(topic: "debro/camera", string: "did disconnect")
        //lastWillMessage.contentType = "JSON"
        lastWillMessage.willResponseTopic = "debro/camera"
        lastWillMessage.willExpiryInterval = .max
        lastWillMessage.willDelayInterval = 0
        lastWillMessage.qos = .qos1
        mqtt5.willMessage = lastWillMessage
        
        
        mqtt5.keepAlive = 60
        mqtt5.delegate = self
        let success = mqtt5.connect()
        
        if success {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                var current_date_string = formatter.string(from: Date())
                //var current_date_string = formatter.string(from: Date())
                print(current_date_string)
                //                mqtt5.publish("debro/water", withString: "run water " + current_date_string , qos: .qos1, DUP: true, retained: false, properties: .init())
                mqtt5.publish("debro/camera", withString: "run waterpump" , qos: .qos1, DUP: true, retained: false, properties: .init())
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                //mqtt5.disconnect()
            }
        } else {
            print("MQTT Connection did not Connected!!")
        }
        
        
        
        
    }
    
    
}
extension PlantInfoVC {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }
        
        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

