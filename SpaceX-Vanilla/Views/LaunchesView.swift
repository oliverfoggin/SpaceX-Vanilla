import SwiftUI

struct MainLaunchView: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    switch (appState.launches, appState.rockets) {
    case (.notRequested, _):
      Text("Not requested")
        .onAppear {
          appState.launchRequest.send()
          appState.rocketRequest.send()
        }
    case (.fetching, _):
      Text("Fetching")
    case (.success, .success):
      LaunchListView(
        launches: appState.compiledLaunchViewModels,
        onTap: appState.selectLaunch(launch:)
      )
    case let (.error(error), _):
      Text(error.localizedDescription)
    default:
      Text("Something")
    }
  }
}

struct LaunchListView: View {
  let launches: [LaunchViewModel]
  let onTap: (Launch) -> Void

  var body: some View {
    Section(header: HeaderView(title: "LAUNCHES")) {
      ForEach(launches) { launch in
        VStack {
          LaunchView(viewModel: launch)
            .onTapGesture { onTap(launch.launch) }
          Divider()
        }
      }
    }
  }
}

struct LaunchView: View {
  let viewModel: LaunchViewModel

  var body: some View {
    HStack(alignment: .top) {
      viewModel.patchImage()
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)

      VStack(alignment: .leading) {
        Text("Mission:")
        Text("Date/time:")
        Text("Rocket:")
        Text(viewModel.daysTitle)
      }
      VStack(alignment: .leading) {
        Text(viewModel.missionName)
        Text(viewModel.dateTime)
        Text(viewModel.rocketInfo)
        Text("\(viewModel.days)")
      }
      Spacer()
      viewModel.successImage
    }
    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
//    .onTapGesture {
//      viewModel.send(.launchTapped(launch: viewModel.launch))
//    }
  }
}

extension LaunchViewModel {
  @ViewBuilder func patchImage() -> some View {
    if let url = launch.patchImageURL {
      RemoteImage(
        url: url.absoluteString,
        loading: Image(systemName: "ellipsis.circle.fill").resizable(),
        failure: Image(systemName: "xmark.circle.fill").resizable()
      )
    } else {
      Image(systemName: "xmark.circle.fill").resizable()
    }
  }
}
