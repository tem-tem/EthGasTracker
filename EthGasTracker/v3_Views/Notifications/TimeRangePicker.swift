import SwiftUI

struct TimeRangePicker: View {
    @State private var startHour: Int = 0
    @State private var startMinute: Int = 0
    @State private var endHour: Int = 0
    @State private var endMinute: Int = 0

    private var hours: [Int] = Array(0...23)
    private var minutes: [Int] = Array(0...59)

    var body: some View {
        Section(header: Text("Off hours"), footer: Text("Alerts will be disabled during these hours.")) {
            HStack {
                Text("Start Time")
                Spacer()
                Picker("Hour", selection: $startHour) {
                    ForEach(hours, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker("Minute", selection: $startMinute) {
                    ForEach(minutes, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)
            }

            HStack {
                Text("End Time")
                Spacer()
                Picker("Hour", selection: $endHour) {
                    ForEach(hours, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)

                Picker("Minute", selection: $endMinute) {
                    ForEach(minutes, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 60)
            }
        }
    }
}

struct TimeRangePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimeRangePicker()
    }
}
