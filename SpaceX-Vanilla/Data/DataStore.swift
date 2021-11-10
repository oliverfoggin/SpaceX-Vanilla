import Foundation
import Combine

class DataStore: ObservableObject {
  @Published var company: Remote<Company, ClientError> = .notRequested
  @Published var launches: Remote<[Launch], ClientError> = .notRequested
  @Published var rockets: Remote<[String : Rocket], ClientError> = .notRequested

  private var cancellables: Set<AnyCancellable> = []

  let spaceXClient: SpaceXClient

  init(spaceXClient: SpaceXClient) {
    self.spaceXClient = spaceXClient
  }

  func fetchSpaceXInfo() {
    spaceXClient.fetchCompanyInfo()
      .map(Remote.success)
      .catch { e in Just(Remote.error(e)) }
      .assign(to: \.company, on: self)
      .store(in: &cancellables)

    spaceXClient.fetchLaunches()
      .map(Remote.success)
      .catch { e in Just(Remote.error(e)) }
      .assign(to: \.launches, on: self)
      .store(in: &cancellables)

    spaceXClient.fetchRockets()
      .map(Remote.success)
      .catch { e in Just(Remote.error(e)) }
      .assign(to: \.rockets, on: self)
      .store(in: &cancellables)
  }
}
