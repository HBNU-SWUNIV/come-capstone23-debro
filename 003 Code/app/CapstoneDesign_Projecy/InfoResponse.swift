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
