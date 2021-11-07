import SwiftUI
import Combine

struct LaunchViewModel: Identifiable, Equatable {
  static func == (lhs: LaunchViewModel, rhs: LaunchViewModel) -> Bool {
    lhs.id == rhs.id
  }

  enum MissionSuccess {
    case success, failure, unknown

    init(success: Bool?) {
      switch success {
      case .none:
        self = .unknown
      case .some(true):
        self = .success
      case .some(false):
        self = .failure
      }
    }
  }

  var id: String
  var launch: Launch
  let missionName: String
  let dateTime: String
  let rocketInfo: String
  let days: Int
  let successImage: Image
  let daysTitle: String

  init(launch: Launch, rocket: Rocket?, now: Date, calendar: Calendar) {
    id = launch.id
    self.launch = launch
    missionName = launch.missionName
    dateTime = "\(Self.dateFormatter.string(from: launch.launchDate)) at \(Self.timeFormatter.string(from: launch.launchDate))"
    if let rocket = rocket {
      rocketInfo = "\(rocket.name) / \(rocket.type)"
    } else {
      rocketInfo = "Unknown"
    }
    days = calendar.numDaysBetween(now, launch.launchDate)
    daysTitle = "Days \(days < 0 ? "since" : "from") now:"

    switch MissionSuccess(success: launch.success) {
    case .success:
      successImage = Image(systemName: "checkmark")
    case .failure:
      successImage = Image(systemName: "xmark")
    case .unknown:
      successImage = Image(systemName: "questionmark")
    }
  }
}

extension LaunchViewModel {
  static let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .none
    return df
  }()

  static let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    return df
  }()
}
