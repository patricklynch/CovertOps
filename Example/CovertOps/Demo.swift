import Foundation

struct DemoDescription {
    let title: String
    let subtitle: String
}

enum Demo: CaseIterable {
    case showDetail, showMultipleAlerts, downloadConcurrentData, observation
    
    var demoDescription: DemoDescription {
        switch self {
        case .showDetail:
            return DemoDescription(
                title: "Show Detail",
                subtitle: "How to present or push a view controller encapsulated in an oepration."
            )
        case .showMultipleAlerts:
            return DemoDescription(
                title: "Show Multiple Alerts",
                subtitle: "How to chain operations together to ensure execution happens one after another in sequence."
            )
        case .downloadConcurrentData:
            return DemoDescription(
                title: "Download Concurrent Data",
                subtitle: "Download from multiple endpoints at once to maximize network performance."
            )
        case .observation:
            return DemoDescription(
                title: "Observation",
                subtitle: "Creating bindings and react to changes in data using operations."
            )
        }
    }
}
