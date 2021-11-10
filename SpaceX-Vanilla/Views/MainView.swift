import SwiftUI
import Combine
import CasePaths

struct MainView: View {
  @ObservedObject var viewModel: MainViewModel

  init(viewModel: MainViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ScrollView {
      LazyVStack {
        CompanyView(companyViewModel: CompanyViewModel(company: viewModel.company))
        LaunchListView(launches: viewModel.launches, onTap: viewModel.launchViewModelTapped(launchViewModel:))
      }
    }
    .confirmationDialog(
      title: { _ in Text("Which info would you like to see?") },
      titleVisibility: .visible,
      unwrap: $viewModel.route,
      case: /MainViewModel.Route.launchActionSheet(launch:),
      actions: { launch in
        launch.actionButtons

        Button(role: .cancel) {
        } label: {
          Text("Cancel")
        }
      },
      message: { _ in EmptyView() }
    )
    .navigationTitle("SpaceX")
    .toolbar {
      ToolbarItem {
        NavigationLink(
          unwrap: $viewModel.route,
          case: /MainViewModel.Route.filter,
          onNavigate: viewModel.setFilterNavigation(isActive:),
          destination: { _ in Text("Filter") },
          label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
          }
        )
      }
    }
  }
}

struct CompanyView: View {
  let companyViewModel: CompanyViewModel

  var body: some View {
    Section(header: HeaderView(title: "COMPANY")) {
      Text(self.companyViewModel.description)
        .padding(8)
    }
  }
}

struct HeaderView: View {
  let title: String

  var body: some View {
    VStack {
      Text(title)
        .foregroundColor(.white)
        .font(.title)
        .padding(4)
    }
    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
    .background(Color(white: 0.2))
  }
}

extension Launch {
  @ViewBuilder var actionButtons: some View {
    if let wiki = wikipediaURL {
      Button {
        UIApplication.shared.open(wiki)
      } label: {
        Text("Wikipedia")
      }
    }
    if let youtubeId = youtubeId {
      Button {
        let url = URL(string: "http://www.youtube.com/watch?v=\(youtubeId)")!
        UIApplication.shared.open(url)
      } label: {
        Text("YouTube")
      }
    }
    if let article = articleURL {
      Button {
        UIApplication.shared.open(article)
      } label: {
        Text("Article")
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let launch = Launch(
      id: "blah",
      missionName: "Blah",
      launchDate: Date(),
      rocketId: "abc",
      youtubeId: "youtubeId"
    )

    let company = Company(
      name: "Bob",
      founder: "Oliver",
      founded: 1,
      employees: 9999,
      launchSites: 123,
      valuation: 42
    )

    let rocket = Rocket(id: "abc", name: "Elon", type: "BFR")

    let launchViewModel = LaunchViewModel(
      launch: launch,
      rocket: rocket,
      now: Date(),
      calendar: .current
    )

    let viewModel = MainViewModel(
      company: company,
      launches: [launchViewModel],
      route: .launchActionSheet(launch: launch)
    )

    return NavigationView {
      MainView(viewModel: viewModel)
    }
  }
}
