//
//  TodosResponse.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation

// MARK: - TodosResponse
// JSON -> struct, class : 디코딩한다
struct InfoResponse: Decodable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
    //    let hey: String
}

struct BaseListResponse<T: Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let message: String?
}

struct BaseResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    //    let code: String?
}

// MARK: - Datum
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

//// MARK: - Data
//struct BaseData: Codable {
//    let humidity: Int?
//    let temperature: Int?
//    let moisture: Int?
//}
struct BaseData: Codable {
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let humidity, temperature, moisture: String?
    let ph: JSONNull?
    let time: String?
    let id: Int?
    enum CodingKeys: String, CodingKey {
        case humidity = "humidity"
        case temperature = "temperature"
        case moisture = "moisture"
        case ph = "ph"
        case time = "time"
        case id = "id"
    }
}

// MARK: - PlantInfoClass
struct PlantInfoClass: Codable {
    let name: String?
    let born_date: String?
}
// MARK: - PlantContainer
struct PlantContainer: Codable {
    //let userName: String?
    let Plants: [PlantExist]?
}
//// MARK: - PlantExist
//struct PlantExist: Codable {
//
//    let plantNumber: Int?
//    let plantName: String?
//    let isExisted: Bool?
//    let birthDate: String?
//
//}

// MARK: - PlantExist
struct PlantExist: Codable {
    let userName: String?
    let plantName: [String?]?
    let isExisted: [Bool]?
    let birthDate: [String?]?
    
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let baseData = try? JSONDecoder().decode(BaseData.self, from: jsonData)


// MARK: - BaseData
struct PlantDatas: Codable {
    let data: [PlantData]?
}

// MARK: - Datum
struct PlantData: Codable {
    let plantNumber: Int?
    let plantName, address: String?
    let isOutside: Int?
    let selectedTitle: String?
    //let length, time: JSONNull?
    let length, time: String?
    let userName: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        plantNumber = try? container.decode(Int.self, forKey: .plantNumber)
        plantName = try? container.decode(String.self, forKey: .plantName)
        address = try? container.decode(String.self, forKey: .address)
        isOutside = try? container.decode(Int.self, forKey: .isOutside)
        selectedTitle = try? container.decode(String.self, forKey: .selectedTitle)
        userName = try? container.decode(String.self, forKey: .userName)
        
        // time 이 null 일 경우 오늘 날짜 리턴 로직
        // For JSON null values, assign empty strings
        let lengthValue = (try? container.decodeIfPresent(String.self, forKey: .length)) ?? ""
        length = lengthValue.isEmpty ? getDateBefore30Days() : lengthValue
        
        // Handle time with custom logic
        let timeValue = (try? container.decodeIfPresent(String.self, forKey: .time)) ?? ""
        time = timeValue.isEmpty ? getDateBefore30Days() : timeValue
        
        // Helper function to get current date in "yyyy-mm-dd" format
        func getCurrentDateString() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }
        
        func getDateBefore30Days() -> String {
            let thirtyDaysBefore = Calendar.current.date(byAdding: .day, value: -133, to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: thirtyDaysBefore)
        }
    }
    
}

// MARK: - WeatherData Struct
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let baseData = try? JSONDecoder().decode(BaseData.self, from: jsonData)

// MARK: - BaseWeatherData
struct BaseWeatherData: Codable {
    let response: Response?
}

// MARK: - Response
struct Response: Codable {
    let header: Header?
    let body: Body?
}

// MARK: - Body
struct Body: Codable {
    let dataType: String?
    let items: Items?
    let pageNo, numOfRows, totalCount: Int?
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let baseDate, baseTime, category: String?
    let nx, ny: Int?
    let obsrValue: String?
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String?
}
// MARK: - imageList
typealias ImageList = [String]


// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
