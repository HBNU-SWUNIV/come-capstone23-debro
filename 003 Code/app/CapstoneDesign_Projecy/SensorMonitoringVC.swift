//
//  SensorMonitoringVC.swift
//  CapstoneDesign_Projecy
//
//  Created by 김종훈 on 2023/05/11.
//

import UIKit
import SwiftUI
import Combine

class SensorMonitoringVC: UIViewController {
    
    enum ApiError : Error {
        case noContent
        case decodingError
        case jsonEncoding
        case unauthorized
        case notAllowedUrl
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info : String {
            switch self {
            case .noContent :           return "데이터가 없습니다."
            case .decodingError :       return "디코딩 에러입니다."
            case .jsonEncoding :        return "유효한 json 형식이 아닙니다."
            case .unauthorized :        return "인증되지 않은 사용자 입니다."
            case .notAllowedUrl :       return "올바른 URL 형식이 아닙니다."
            case let .badStatus(code):  return "에러 상태코드 : \(code)"
            case .unknown(let err):     return "알 수 없는 에러입니다 \n \(err)"
            }
        }
    }

    var dataHumi: String?
    var dataTemp: String?
    var dataMois: String?
    
    
    @StateObject var infoVM: InfoVM = InfoVM()
    
    @IBOutlet weak var dataLabel: UILabel!
    
  
    @IBOutlet weak var dataTemperatureLabel: UILabel!
    
    
    @IBOutlet weak var dataMoistureLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VC loaded")
        
        dataLabel.text = "Humidity :"
        dataMoistureLabel.text = "Moisture :"
        dataTemperatureLabel.text = "Temperature :"
       
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        InfoVM()
    }
    
    
    
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {

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
                    
                    print(baseResponse.data?.humidity)
                    print(baseResponse.data?.moisture)
                    print(baseResponse.data?.temperature)
                    
                    guard let humidity = baseResponse.data?.humidity else {
                        return
                    }
                    guard let moisture = baseResponse.data?.moisture else {
                        return
                    }
                    guard let temperature = baseResponse.data?.temperature else {
                        return
                    }
                    
//                    self.dataHumi = humidity
//                    self.dataMois = moisture
//                    self.dataTemp = temperature
                    
                    
                    print("습도: " + humidity)
                    print("수분: " + moisture)
                    print("온도: " + temperature)
                    
                    DispatchQueue.main.async {
                        self.dataLabel.text = "Humidity :" + humidity
                        self.dataMoistureLabel.text = "Moisture :" + moisture
                        self.dataTemperatureLabel.text = "Temperature :" + temperature
                                               }
                    
//                    self.dataLabel.text = "Humidity :" + humidity
//                    self.dataMoistureLabel.text = "Moisture :" + moisture
//                    self.dataTemperatureLabel.text = "Temperature :" + temperature
                    
                    
                    //print(baseResponse)
                    
                    //completion(.success(baseResponse))
                } catch {
                  // decoding error
                    //completion(.failure(ApiError.decodingError))
                }
              }
            
        }.resume()
        
        dataLabel.text = dataHumi
        dataMoistureLabel.text = dataMois
        dataTemperatureLabel.text = dataTemp
        
        
        //dataHumidityLabel.text = "빡코딩중이야~~"
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    static func fetchAData(completion: @escaping (Result<BaseData, ApiError>) -> Void){
//
//        // 1. urlRequest 를 만든다
//
//        let urlString = "http://hyunul.com/sensor"
//        
//        guard let url = URL(string: urlString) else {
//            return completion(.failure(ApiError.notAllowedUrl))
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//
//        // 2. urlSession 으로 API를 호출한다
//        // 3. API 호출에 대한 응답을 받는다
//        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
//
//            //print("data: \(data)")
//            //print("urlResponse: \(urlResponse)")
//            //print("err: \(err)")
//
//
//            if let error = err {
//                return completion(.failure(ApiError.unknown(error)))
//            }
//
//            guard let httpResponse = urlResponse as? HTTPURLResponse else {
//                print("bad status code")
//                return completion(.failure(ApiError.unknown(nil)))
//            }
//
//            switch httpResponse.statusCode {
//            case 401:
//                return completion(.failure(ApiError.unauthorized))
//            case 204:
//                return completion(.failure(ApiError.noContent))
//
//            default: print("default")
//            }
//
//            if !(200...299).contains(httpResponse.statusCode){
//                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
//            }
//
//            if let jsonData = data {
//                // convert data to our swift model
//                do {
//                    // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
//                  let baseResponse = try JSONDecoder().decode(BaseData.self, from: jsonData)
////                    let humidity = baseResponse.humidity
////                    let moisture = baseResponse.moisture
////                    let temperature = baseResponse.temperature
////                    print("습도: " + String(humidity))
////                    print("수분: " + String(moisture))
////                    print("온도: " + String(temperature))
//                    print(baseResponse)
//
//                    completion(.success(baseResponse))
//                } catch {
//                  // decoding error
//                    completion(.failure(ApiError.decodingError))
//                }
//              }
//
//        }.resume()
//    }
    
    fileprivate func handleError(_ err: Error) {
        
        if err is UserInfoAPI.ApiError {
            let apiError = err as! UserInfoAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증안됨")
            default:
                print("default")
            }
        }
        
    }// handleError
}
