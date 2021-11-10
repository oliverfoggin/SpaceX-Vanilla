import Foundation
import Combine

class AppViewModel: ObservableObject {
  typealias AppViewModelState = State<(Company, [LaunchViewModel]), AppViewModelError>

  enum AppViewModelError: String, Error {
    case fubar
    case noIdea
  }

  @Published var state: AppViewModelState = .idle

  private let dataStore: DataStore

  private var cancellables: Set<AnyCancellable> = []

  init(dataStore: DataStore) {
    self.dataStore = dataStore

    dataStore.$company
      .zip(dataStore.$launches, dataStore.$rockets) { (c, l, r) -> AppViewModelState in
        switch (c, l, r) {
        case (.notRequested, .notRequested, .notRequested):
          return .idle
        case let (.success(c), .success(l), .success(r)):
          return .success((c, AppViewModel.compileLaunchViewModels(launches: l, rockets: r, now: Date(), calendar: .current)))
        case (.fetching, _, _), (_, .fetching, _), (_, _, .fetching):
          return .loading
        case (.error, _, _), (_, .error, _), (_, _, .error):
          return .error(.fubar)
        default:
          return .error(.noIdea)
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.state, on: self)
      .store(in: &cancellables)
  }

  func start() {
    dataStore.fetchSpaceXInfo()
  }
}

extension AppViewModel {
  static func compileLaunchViewModels(launches: [Launch], rockets: [String: Rocket], now: Date, calendar: Calendar) -> [LaunchViewModel] {
    launches.sorted(by: \.launchDate, using: (<))
      .filter { _ in
        return true
//        switch self.filterState.successFilter {
//        case .all:
//          return true
//        case .successful:
//          return launch.success ?? false
//        case .unsuccessful:
//          return !(launch.success ?? true)
//        }
      }
      .filter { _ in
        return true
//        switch self.filterState.year {
//        case "All":
//          return true
//        case let year:
//          guard let yearInt = Int(year),
//                calendar.component(.year, from: launch.launchDate) == yearInt
//          else {
//            return false
//          }
//          return true
//        }
      }
      .map { launch -> LaunchViewModel in
        LaunchViewModel(
          launch: launch,
          rocket: rockets[launch.rocketId],
          now: now,
          calendar: calendar
        )
      }
  }
}
