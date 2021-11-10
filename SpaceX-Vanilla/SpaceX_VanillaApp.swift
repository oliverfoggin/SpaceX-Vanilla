import SwiftUI

@main
struct SpaceX_VanillaApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        viewModel: AppViewModel(
          dataStore: DataStore(
            spaceXClient: SpaceXLive()
          )
        )
      )
    }
  }
}
