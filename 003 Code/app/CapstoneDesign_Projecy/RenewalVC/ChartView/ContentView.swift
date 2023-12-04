import SwiftUI
import Charts
import Combine

struct ChartDataResponse: Decodable {
    let data: [PlantData_height]
}

struct PlantData_height: Identifiable, Decodable {
    var id = UUID()
    var pheightH: [Double]
    var pheightL: [Double]
    var plantName: String?
    var weekDate: String? // 각 데이터 포인트에 대한 주간 날짜

    var averageHeight: Double {
        let averageH = pheightH.isEmpty ? 0 : pheightH.reduce(0, +) / Double(pheightH.count)
        let averageL = pheightL.isEmpty ? 0 : pheightL.reduce(0, +) / Double(pheightL.count)
        return (averageH + averageL) / 2
    }
    
    enum CodingKeys: String, CodingKey {
        case pheightH, pheightL, plantName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plantName = try container.decodeIfPresent(String.self, forKey: .plantName)
        
        let pheightHString = try container.decode(String.self, forKey: .pheightH)
        let pheightLString = try container.decode(String.self, forKey: .pheightL)
        pheightH = pheightHString.trimmingCharacters(in: ["[", "]"])
                    .split(separator: ",")
                    .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        pheightL = pheightLString.trimmingCharacters(in: ["[", "]"])
                    .split(separator: ",")
                    .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }

    mutating func generateWeekDate(forIndex index: Int) {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: today)

        // 현재 날짜로부터 이전 월요일을 찾습니다.
        if components.weekday != 2 {
            let daysToSubtract = components.weekday! - 2
            components.day! -= daysToSubtract
        }

        // index에 따라 추가적인 일 수 계산 (과거 방향으로)
        components.day! -= 7 * index

        // 새로운 날짜 생성
        if let newDate = calendar.date(from: components) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            weekDate = dateFormatter.string(from: newDate)
        }
    }
}

struct ContentView: View {
    @State private var chartData: [PlantData_height] = []
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack {
            Chart(chartData) { plantData in
                LineMark(
                    x: .value("Date", plantData.weekDate ?? ""),
                    y: .value("Average Height", plantData.averageHeight)
                )
            }
        }
        .onAppear {
            requestData()
        }
    }

    func requestData() {
        let url = URL(string: "http://hyunul.com/length/all")!
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ChartDataResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Error: \(error)")
                }
            }, receiveValue: { response in
                var updatedData = response.data
                let dataCount = updatedData.count
                for (index, var plantData) in updatedData.enumerated() {
                    // 배열의 마지막 요소부터 시작하여 날짜를 생성합니다.
                    let reverseIndex = dataCount - 1 - index
                    plantData.generateWeekDate(forIndex: reverseIndex)
                    updatedData[index] = plantData
                }
                self.chartData = updatedData
            })
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

