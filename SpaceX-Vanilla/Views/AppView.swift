import SwiftUI

struct AppView: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    NavigationView {
      switch appState.company {
      case .notRequested:
        Text("Not fetched yet")
          .onAppear { appState.companyRequest.send() }
      case .fetching:
        ProgressView()
          .progressViewStyle(.circular)
      case .success:
        MainView()
      case let .error(e):
        Text(e.localizedDescription)
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      appState: .init()
    )
  }
}
