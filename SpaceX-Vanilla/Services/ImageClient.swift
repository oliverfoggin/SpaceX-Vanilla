import Combine
import UIKit

protocol ImageClient {
  func downloadImage(from url: URL) -> AnyPublisher<UIImage, Never>
}

struct ImageClientLive: ImageClient {
  func downloadImage(from url: URL) -> AnyPublisher<UIImage, Never> {
    URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .map(UIImage.init(data:))
      .replaceNil(with: UIImage(systemName: "xmark.circle.fill")!)
      .catch { _ in Just(UIImage(systemName: "xmark.circle.fill")!) }
      .eraseToAnyPublisher()
  }
}
