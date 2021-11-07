import Foundation
import Combine

enum Remote<T, RemoteError: Error> {
  case notRequested
  case fetching
  case success(T)
  case error(RemoteError)
}

class AppState: ObservableObject {
  enum Route {
    case filter
    case launchActionSheet(launch: Launch)
  }

  @Published private(set) var selectedLaunch: Launch?
  @Published var route: Route?

  @Published var company: Remote<Company, ClientError> = .notRequested
  let companyRequest = PassthroughSubject<Void, Never>()

  @Published var launches: Remote<[Launch], ClientError> = .notRequested
  let launchRequest = PassthroughSubject<Void, Never>()

  @Published var rockets: Remote<[String: Rocket], ClientError> = .notRequested
  let rocketRequest = PassthroughSubject<Void, Never>()

  @Published var compiledLaunchViewModels: [LaunchViewModel] = []

  private let spaceXClient: SpaceXClient = SpaceXLive()
  private var cancellables: Set<AnyCancellable> = []

  init() {
    companyRequest
      .flatMapFirst {
        self.spaceXClient.fetchCompanyInfo()
          .onStart { _ in self.company = .fetching }
          .map(Remote.success)
          .catch { e in Just(Remote.error(e)) }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.company, on: self)
      .store(in: &cancellables)

    launchRequest
      .flatMapFirst {
        self.spaceXClient.fetchLaunches()
          .onStart { _ in self.launches = .fetching }
          .map(Remote.success)
          .catch { e in Just(Remote.error(e)) }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.launches, on: self)
      .store(in: &cancellables)

    rocketRequest
      .flatMapFirst {
        self.spaceXClient.fetchRockets()
          .onStart { _ in self.rockets = .fetching }
          .map(Remote.success)
          .catch { e in Just(Remote.error(e)) }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.rockets, on: self)
      .store(in: &cancellables)

    $company
      .sink { v in dump(v) }
      .store(in: &cancellables)

    $launches.zip($rockets)
      .map { [weak self] in
        switch $0 {
        case let (.success(launches), .success(rockets)):
          return self?.compileLaunchViewModels(
            launches: launches,
            rockets: rockets,
            now: Date(),
            calendar: .current
          ) ?? []
        default:
          return []
        }
      }
      .assign(to: \.compiledLaunchViewModels, on: self)
      .store(in: &cancellables)
  }

  func selectLaunch(launch: Launch) {
    route = .launchActionSheet(launch: launch)
  }
}

extension AppState {
  func compileLaunchViewModels(launches: [Launch], rockets: [String: Rocket], now: Date, calendar: Calendar) -> [LaunchViewModel] {
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

extension Publisher {
  func onStart (
    perform f: @escaping (Subscription) -> Void
  ) -> Publishers.HandleEvents<Self> {
    handleEvents( receiveSubscription: f )
  }
}

public extension Publisher {
  func flatMapFirst<P: Publisher>(
    _ transform: @escaping (Output) -> P
  ) -> Publishers.FlatMap<Publishers.HandleEvents<P>, Publishers.Filter<Self>>
  where Self.Failure == P.Failure {
    var isRunning = false
    let lock = NSRecursiveLock()

    func set(isRunning newValue: Bool) {
      defer { lock.unlock() }
      lock.lock()

      isRunning = newValue
    }

    return self
      .filter { _ in !isRunning }
      .flatMap { output in
        transform(output)
          .handleEvents(
            receiveSubscription: { _ in
              set(isRunning: true)
            },
            receiveCompletion: { _ in
              set(isRunning: false)
            },
            receiveCancel: {
              set(isRunning: false)
            }
          )
      }
  }
}
