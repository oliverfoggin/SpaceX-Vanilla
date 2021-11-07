import UIKit

struct Launch: Identifiable, Equatable {
  enum PatchImageRequest: Equatable {
    case none
    case downloading
    case complete(image: UIImage)
    case failed
  }

  var id: String
  var missionName: String
  var launchDate: Date
  var rocketId: String
  var patchImageURL: URL?
  var success: Bool?
  var wikipediaURL: URL?
  var youtubeId: String?
  var articleURL: URL?
  var patchImage: PatchImageRequest = .none
}

extension Launch: Decodable {
  enum RootKeys: String, CodingKey {
    case id
    case missionName = "name"
    case launchDate = "date_utc"
    case rocketId = "rocket"
    case links
    case success
  }

  enum LinkKeys: String, CodingKey {
    case patch, youtubeId = "youtube_id", wikipedia, article
  }

  enum PatchKeys: String, CodingKey {
    case small
  }

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootKeys.self)

    let linksContainer = try rootContainer.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)

    let patchContainer = try linksContainer.nestedContainer(keyedBy: PatchKeys.self, forKey: .patch)

    id = try rootContainer.decode(String.self, forKey: .id)
    missionName = try rootContainer.decode(String.self, forKey: .missionName)
    launchDate = try rootContainer.decode(Date.self, forKey: .launchDate)
    rocketId = try rootContainer.decode(String.self, forKey: .rocketId)
    patchImageURL = try? patchContainer.decode(URL.self, forKey: .small)
    success = try? rootContainer.decode(Bool.self, forKey: .success)
    wikipediaURL = try? linksContainer.decode(URL.self, forKey: .wikipedia)
    youtubeId = try? linksContainer.decode(String.self, forKey: .youtubeId)
    articleURL = try? linksContainer.decode(URL.self, forKey: .article)
  }
}
