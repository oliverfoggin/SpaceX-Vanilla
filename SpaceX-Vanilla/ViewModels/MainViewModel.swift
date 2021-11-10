import Combine
import Foundation

class MainViewModel: ObservableObject {
  enum Route {
    case filter
    case launchActionSheet(launch: Launch)
  }

  @Published var route: Route?

  var company: Company
  var launches: [LaunchViewModel]

  init(
    company: Company,
    launches: [LaunchViewModel],
    route: Route? = nil
  ) {
    self.company = company
    self.launches = launches
    self.route = route
  }

  func launchViewModelTapped(launchViewModel: LaunchViewModel) {
    let launch = launchViewModel.launch

    if launch.youtubeId == nil &&
        launch.wikipediaURL == nil &&
        launch.articleURL == nil {
      return
    }

    self.route = .launchActionSheet(launch: launchViewModel.launch)
  }

  func setFilterNavigation(isActive: Bool) {
    route = isActive ? .filter : nil
  }
}
