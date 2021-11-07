import SwiftUI
import Combine
import CasePaths

struct MainView: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    ScrollView {
      LazyVStack {
        if case let .success(company) = appState.company {
          CompanyView(companyViewModel: CompanyViewModel(company: company))
        } else {
          EmptyView()
        }
        MainLaunchView()
      }
    }
    .confirmationDialog(
      title: { _ in Text("Which info would you like to see?") },
      titleVisibility: .visible,
      unwrap: $appState.route,
      case: /AppState.Route.launchActionSheet(launch:),
      actions: { launch in
        if let wiki = launch.wikipediaURL {
          Button {
            UIApplication.shared.open(wiki)
          } label: {
            Text("Wikipedia")
          }
        }
        if let youtubeId = launch.youtubeId {
          Button {
            let url = URL(string: "http://www.youtube.com/watch?v=\(youtubeId)")!
            UIApplication.shared.open(url)
          } label: {
            Text("YouTube")
          }
        }
        if let article = launch.articleURL {
          Button {
            UIApplication.shared.open(article)
          } label: {
            Text("Article")
          }
        }
      },
      message: { _ in EmptyView() }
    )
    .navigationTitle("SpaceX")
    .toolbar {
      ToolbarItem {
        NavigationLink(
          unwrap: $appState.route,
          case: /AppState.Route.filter,
          onNavigate: { appState.route = $0 ? .filter : nil },
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

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      MainView()
        .environmentObject(AppState())
    }
  }
}
