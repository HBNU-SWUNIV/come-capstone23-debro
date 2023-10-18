//
//  ContentView.swift
//  ChartView
//
//  Created by 김종훈 on 2023/08/03.
//

import Charts
import SwiftUI

// 밑에서 쭉 설명할 Marks에 대해서도 동일한 Postings 데이터 적용
//struct Posting: Identifiable {
//  let name: String
//  let count: Int
//
//  var id: String { name }
//}
//
//let postings: [Posting] = [
//  .init(name: "Green", count: 250),
//  .init(name: "James", count: 100),
//  .init(name: "Tony", count: 70)
//]
//
//// 차트 그리기
//struct ContentView: View {
//  var body: some View {
//    Chart {
//      ForEach(postings) { posting in
//        RuleMark(
//          xStart: .value("Posting", posting.count),
//          xEnd: .value("Posting", posting.count + 20),
//          y: .value("Name", posting.name)
//        )
//      }
//    }
//  }
//}


struct ContentView: View {
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
            //.frame(width: 300, height: 300)
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
