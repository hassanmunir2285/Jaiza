import WidgetKit
import SwiftUI

struct provider: TimelineProvider {
    // Method to retrive data from Flutter app

    private func getDataFromFlutter() -> SimpleEntry {
        let userDefault = UserDefaults(suiteName: "group.homeScreenApp")
        let textFromFlutterApp = userDefault.string(forKey: "text_from_flutter_app") ?? "0"
        return SimpleEntry(data: Date(), text: textFromFlutterApp)
    }

    //preview in widget gallery

    func placeholder(incontext: Context) -> SimpleEntry {
        SimpleEntry(data: Date(), text: "0")
    }

    // widget gallery/selection preview

    func getSnapshot(incontext: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(entry)
    }

    // Actual widget on home screen

    func getTimeline(incontext: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getDataFromFlutter()

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// This represents the data structure for our widget
struct SimpleEntry: TimelineEntry {
    let data: Date
    let text: String
}

// The main widget configuration

struct MyHomeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Text:")
            Text(entry.text)
        }
    }
}

// The main widget configuration
struct MyHomeWidget: Widget {
    let kind: String = "MyHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MyHomeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MyHomeWidgetEntryView(entry: entry)
                .padding()
                .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
#Preview(as: .systemSmall) {
    MyHomeWidget()

}timeline: {
    SimpleEntry(data: .now, text: "0")
    SimpleEntry(data: .now, text: "0")
}

























