//
//  ContentView.swift
//  ChartView
//
//  Created by 김종훈 on 2023/08/03.
//

import Charts
import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var chartData: [ChartData] = []
    @State private var cancellable: AnyCancellable?

    func requestData() {
        let url = URL(string: "YOUR_API_ENDPOINT")!

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [ChartData].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Error: \(error)")
                }
            }, receiveValue: { data in
                self.chartData = data
            })
    }

    
    var body: some View {
        VStack {
            // dataRequest 로직 추가
            Chart {
                LineMark(
                    x: .value("Mount", "9월 7일"),
                    y: .value("Value", 3.4)
                )
                LineMark(
                    x: .value("Mount", "9월 14일"),
                    y: .value("Value", 7.1)
                )
                LineMark(
                    x: .value("Mount", "9월 21일"),
                    y: .value("Value", 13.6)
                )
            }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//import SwiftUI
//import Combine
//
//struct ChartData: Identifiable {
//    var id = UUID()
//    var date: String
//    var value: Double
//}
//
//struct ContentView: View {
//    @State private var chartData: [ChartData] = []
//    @State private var cancellable: AnyCancellable?
//    
//    var body: some View {
//        VStack {
//            ForEach(chartData) { data in
//                LineMark(
//                    x: .value("Mount", data.date),
//                    y: .value("Value", data.value)
//                )
//            }
//        }
//        .onAppear {
//            requestData()
//        }
//    }
//    
//    func requestData() {
//        let url = URL(string: "YOUR_API_ENDPOINT")!
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { $0.data }
//            .decode(type: [ChartData].self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished: break
//                case .failure(let error): print("Error: \(error)")
//                }
//            }, receiveValue: { data in
//                self.chartData = data
//            })
//    }
//}
