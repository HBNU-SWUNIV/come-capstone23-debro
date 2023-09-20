//
//  CameraVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/05/11.
//

import UIKit
import MQTTNIO
import AWSS3
import CocoaMQTT
import CocoaMQTTWebSocket





class CameraVC: UIViewController, CocoaMQTT5Delegate{
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    let bucketName = "myapp-bucketname"
    let accessKey = "SSGASLNTTCLXGJNPRLNE"
    let secretKey = "60ayImDHNVF+HmgP5TCrOzvLIspqBFmpbKShOfxA"
    let utilityKey = "utility-key"
    var fileKey = "profile/image/"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let tuConf = AWSS3TransferUtilityConfiguration()
        tuConf.isAccelerateModeEnabled = false
        
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: utilityKey
        )
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd/"
        fileKey += dateFormat.string(from: Date())
        fileKey += String(Int64(Date().timeIntervalSince1970)) + "_"
        fileKey += UUID().uuidString + ".png"
        
    }
    
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        
        // 58.233.72.16 2883 topic은 debro/camera로 구독했으며 카메라 실행 명령은 run camera 입니다
        //        let client = MQTTClient(
        //            configuration: .init(
        //                target: .host("58.233.72.16", port: 2883)
        //            ),
        //            eventLoopGroupProvider: .createNew
        //        )
        //        client.connect()
        //
        //        client.whenConnected { response in
        //            print("Connected, is session present: \(response.isSessionPresent)")
        //        }
        //
        //
        //        client.subscribe(to: "debro/camera")
        //        client.publish("run camera", to: "debro/camera")
        
        
        
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
        
        let lastWillMessage = CocoaMQTT5Message(topic: "debro/camera", string: "run camera from Macbook Air")
        //lastWillMessage.contentType = "JSON"
        lastWillMessage.willResponseTopic = "debro/camera"
        lastWillMessage.willExpiryInterval = .max
        lastWillMessage.willDelayInterval = 0
        lastWillMessage.qos = .qos2
        
        //mqtt5.willMessage = lastWillMessage
        mqtt5.keepAlive = 60
        mqtt5.delegate = self
        mqtt5.connect()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            var current_date_string = formatter.string(from: Date())
            //var current_date_string = formatter.string(from: Date())
            print(current_date_string)
            mqtt5.publish("debro/camera", withString: "run camera " + current_date_string , qos: .qos1, DUP: true, retained: false, properties: .init())
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            //mqtt5.disconnect()
        }
        
        
    }
    
    
    
    
    
    
    @IBAction func getButtonTapped(_ sender: UIButton) {
        
        
        //download()
        
        let urladdress = "https://picsum.photos/300"
        
        let url = URL(string: urladdress) //입력받은 url string을 URL로 변경
        //main thread에서 load할 경우 URL 로딩이 길면 화면이 멈춘다.
        //이를 방지하기 위해 다른 thread에서 처리함.
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url!) {
                if let image = UIImage(data: data) {
                    //UI 변경 작업은 main thread에서 해야함.
                    DispatchQueue.main.async {
                        self?.photoImageView.image = image
                    }
                }
            }
        }
        
        
        
        
        //downloadImageFromS3()
        
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    ///
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
            //or
            //let subscriptions : [MqttSubscription] = [MqttSubscription(topic: "chat/room/animals/client/+"),MqttSubscription(topic: "chat/room/foods/client/+"),MqttSubscription(topic: "chat/room/trees/client/+")]
            //mqtt.subscribe(subscriptions)
            
            //            let chatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
            //            chatViewController?.mqtt5 = mqtt5
            //            chatViewController?.mqttVersion = mqttVesion
            //            navigationController!.pushViewController(chatViewController!, animated: true)
            
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
    
    
    
}

let myCert = "myCert"

extension CameraVC: CocoaMQTTDelegate {
    
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
}
extension Optional {
    // Unwrap optional value for printing log only
    var description: String {
        if let self = self {
            return "\(self)"
        }
        return ""
    }
    
}
extension CameraVC {
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

extension CameraVC {
    
    func upload() {
        guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: utilityKey)
        else
        {
            return
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl") //URL로 이미지 읽을 수 있도록 권한 설정 (이 헤더 없으면 못읽음)
        expression.progressBlock = {(task, progress) in
            print("progress \(progress.fractionCompleted)")
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { [weak self] (task, error) -> Void in
            guard let self = self else { return }
            print("task finished")
            
            let url = AWSS3.default().configuration.endpoint.url
            let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(self.fileKey)
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
        
        
        
        guard let data = UIImage(named: "img")?.pngData()
        else
        {
            return
        }
        
        transferUtility.uploadData(data as Data, bucket: bucketName, key: fileKey, contentType: "image/png", expression: expression,
                                   completionHandler: completionHandler).continueWith
        {
            (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
                
            }
            
            if let _ = task.result {
                print ("upload successful.")
            }
            
            return nil
        }
    }
    
    
    
    func download() {
        
        
        guard let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: utilityKey)
        else
        {
            return
        }
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            print("progress \(progress.fractionCompleted)")
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, url, data, err) -> Void in
            print("task finished")
            
            DispatchQueue.main.async { [weak self] in
                
                if let d = data {
                    print("img data 있음")
                    self?.photoImageView.image = UIImage(data: d)
                }
            }
        }
        transferUtility.downloadData(fromBucket: bucketName, key: fileKey, expression: expression, completionHandler: completionHandler).continueWith
        {
            (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let _ = task.result {
                print ("download successful.")
            }
            return nil
        }
    }
}
