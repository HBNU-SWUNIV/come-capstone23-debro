import SwiftUI
import Charts

struct SingleLine {
    var city: String
    var date: Date
    var hoursOfSunshine: Double


    init(city: String, month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.city = city
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
    }
}


var data: [SingleLine] = [
    SingleLine(city: "Seattle", month: 1, hoursOfSunshine: 74),
    SingleLine(city: "Cupertino", month: 1, hoursOfSunshine: 196),
    // ...
    SingleLine(city: "Seattle", month: 12, hoursOfSunshine: 62),
    SingleLine(city: "Cupertino", month: 12, hoursOfSunshine: 199)
]


var body: some View {
    Chart(data) {
        LineMark(
            x: .value("Month", $0.date),
            y: .value("Hours of Sunshine", $0.hoursOfSunshine)
        )
        .foregroundStyle(by: .value("City", $0.city))
    }
}
