//
//  PlantPicVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/09/06.
//


import UIKit
import SnapKit
import Then
import AWSS3
import CocoaMQTT
import CocoaMQTTWebSocket

class PlantPicVC: UIViewController {
    
    
    // 이미지 다른거 땡겨오기
    // 최근에 찍힌 날짜 서버로부터 땡겨오기 -> 이전 뷰컨에서 request시 땡겨올 것
    // requstdata() <- 사진 다른거 땡겨오는 로직 추가할 것
    // dayDifference에 따른 UI내용 변경 로직 추가할 것
    
    var plantName: String?
    var birthDate: String?
    var plant_number: Int?
    var selectedDate: String?
    var recentPictDate: String?
    var dayDifference: Int = 0
    
    let accessKey: String = "AKIAZJGVIYOU6JH5ZN4C"
    let newAccessKey: String = "AKIAZJGVIYOUSHEJSS76"
    let secretKey: String = "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"
    let newSecretKey: String = "yNjlUvkeQNzzn8XJV67LqRePSa9uIinbleiLr7Wz"
    let s3BucketName = "capston-bucket"
    let s3ObjectKey = "image_20230907_205731.jpg"
    let utilityKey = "utility-key2"
    var fileKey = "plant_image/"
    let viewCornerRadius: CGFloat = 10
    
    
    var picFileURL: URL?
    
    
    @IBOutlet weak var detailMainLabel: UILabel!
    @IBOutlet weak var detailDesLabel: UILabel!
    @IBOutlet weak var checkRecentPicLabel: UILabel!
    
    @IBOutlet weak var plantPicView: UIView!
    @IBOutlet weak var takePicView: UIView!
    
    @IBOutlet weak var saveBtnView: UIButton!
    
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("PlantPicVC viewDidLoad!!")
        recentPictDate = "2023-10-11" // 테스트
        setUpAWSS3()
        //requestimage() // <- 사진 다른거 땡겨오는 로직 추가할 것
        calculatedifDate()
        setUpUI()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("PlantViewController Will be Appeared!")
        
        if checkIfFileURLExists(){
            
            if let savedURL = UserDefaults.standard.url(forKey: "picFilePath2") {
                self.picFileURL = savedURL
            }
            
            do {
                //let imageData = try Data(contentsOf: picFileURL)
                guard let unwrappedURL = picFileURL else {
                    print("picFileURL2 is nil")
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
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        print("backButtonTapped!")
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("saveButtonTapped!")
        
        // 선택된 날짜 (실제로는 다른 방법으로 날짜를 가져와야 함)
                //let selectedDate = "2023-10-10" // 예시 문자열, 실제로는 선택된 날짜 문자열을 사용

                // 알림 생성
                let alert = UIAlertController(title: "이미지 저장",
                                              message: "\(selectedDate!)의 사진을 저장하시겠습니까?",
                                              preferredStyle: .alert)
                
                // "예" 버튼 생성
                alert.addAction(UIAlertAction(title: "예", style: .default, handler: { action in
                    // "예"를 선택한 경우, 이미지 저장
                    if let imageToSave = self.plantImageView.image {
                        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        print("Error: No image found")
                    }
                }))
                
                // "아니오" 버튼 생성
                alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
                
                // 알림 표시
                present(alert, animated: true)
        
        
    }
    // 저장 결과에 대한 콜백 함수
        @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                // Save 실패: 오류 메시지 표시
                let alert = UIAlertController(title: "저장 실패",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
            } else {
                // Save 성공: 성공 메시지 표시
                let alert = UIAlertController(title: "저장 성공",
                                              message: "이미지가 성공적으로 저장되었습니다.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
            }
        }
    
    // 오늘의 모습 찍기 로직 추가할 것
    
    @IBAction func takePicButtonTapped(_ sender: UIButton) {
        print("takePicButtonTapped!")
        var formatter = DateFormatter()
        
        takePicRequest()
        
    }
    
    func setUpUI(){
        changeLabelText()
        // dayDifference == 0 일 경우 Label, Button UI 수정 로직 추가
        plantPicView.layer.cornerRadius = viewCornerRadius
        plantPicView.clipsToBounds = true
        
        takePicView.layer.cornerRadius = viewCornerRadius
        takePicView.clipsToBounds = true
        
        saveBtnView.layer.cornerRadius = 3
        saveBtnView.clipsToBounds = true
        
        
    }
    func calculatedifDate(){
        let dateFormatter = DateFormatter()
        
        // 문자열을 Date로 변환
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: recentPictDate!) {
            print("Converted RecentDate:", date)
            
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
    }
    
    func changeLabelText(){
        detailMainLabel.text = (plantName ?? "nil") + "의 모습"
        detailDesLabel.text = (selectedDate ?? "") + "당시의 모습이에요"
    }
            
    func requestimage(){
        
        
        if let savedURL = UserDefaults.standard.url(forKey: "picFileURL2") {
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
                        
                        
                        let fileURL = documentsURL.appendingPathComponent("test_image2.jpg")
                        
                        self?.picFileURL = fileURL
                        
                        print(#fileID, #function, #line, "- self.picFileURL == \(String(describing: self?.picFileURL))")
                        
                        UserDefaults.standard.set(fileURL, forKey: "picFilePath2")
                        
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
        if let savedPath = UserDefaults.standard.string(forKey: "picFilePath2") {
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
  
        fileKey += "image_20230830_201810.jpg"
        
        print(fileKey)
    }
    
}
extension PlantPicVC: CocoaMQTTDelegate, CocoaMQTT5Delegate{
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
    
    func takePicRequest(){
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
        
        let lastWillMessage = CocoaMQTT5Message(topic: "debro/camera", string: "did disconnected")
        //lastWillMessage.contentType = "JSON"
        lastWillMessage.willResponseTopic = "debro/camera"
        lastWillMessage.willExpiryInterval = .max
        lastWillMessage.willDelayInterval = 0
        lastWillMessage.qos = .qos1
        mqtt5.willMessage = lastWillMessage
        
        mqtt5.keepAlive = 60
        mqtt5.delegate = self
        //mqtt5.connect()
        let success = mqtt5.connect()
        
        if success {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                var current_date_string = formatter.string(from: Date())
                //var current_date_string = formatter.string(from: Date())
                print(current_date_string)
                mqtt5.publish("debro/camera", withString: "run camera " + current_date_string , qos: .qos1, DUP: true, retained: false, properties: .init())
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                mqtt5.disconnect()
            }
        } else {
            print("MQTT Connection did not Connected!!")
        }
        
        
    }
    
}
extension PlantPicVC {
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
