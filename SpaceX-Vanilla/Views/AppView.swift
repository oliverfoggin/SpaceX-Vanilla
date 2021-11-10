import SwiftUI
import Combine

struct AppView: View {
  @ObservedObject var viewModel: AppViewModel

  var body: some View {
    NavigationView {
      switch viewModel.state {
      case .idle:
        ProgressView()
          .onAppear(perform: viewModel.start)
      case .loading:
        ProgressView()
      case let .error(error):
        let _ = print("WTF")
        Text(error.localizedDescription)
      case let .success((company, launches)):
        MainView(viewModel: MainViewModel(company: company, launches: launches))
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  struct MockSpaceXClient: SpaceXClient {
    func fetchCompanyInfo() -> AnyPublisher<Company, ClientError> {
      Result.Publisher(
        .success(
          Company(
            name: "Bob",
            founder: "Oliver",
            founded: 1,
            employees: 9999,
            launchSites: 123,
            valuation: 42
          )
        )
      )
        .eraseToAnyPublisher()
    }

    func fetchLaunches() -> AnyPublisher<[Launch], ClientError> {
      Result.Publisher(
        .success([
        Launch(
          id: "zxcvbnm",
          missionName: "Desert Eagle",
          launchDate: Date(),
          rocketId: "abc"
        )
      ])
      )
        .eraseToAnyPublisher()
    }

    func fetchRockets() -> AnyPublisher<[String : Rocket], ClientError> {
      Result.Publisher(
        .success(
          ["abc": Rocket(id: "abc", name: "Elon", type: "BFR")]
        )
      )
        .eraseToAnyPublisher()
    }
  }

  static var previews: some View {
    AppView(
      viewModel: AppViewModel(
        dataStore: DataStore(
          spaceXClient: MockSpaceXClient()
        )
      )
    )
  }
}
