import Foundation
import Combine

struct ClientError: Error, Equatable {
  let message: String?
}

protocol SpaceXClient {
  func fetchCompanyInfo() -> AnyPublisher<Company, ClientError>
  func fetchLaunches() -> AnyPublisher<[Launch], ClientError>
  func fetchRockets() -> AnyPublisher<[String: Rocket], ClientError>
}

struct SpaceXLive: SpaceXClient {
  func fetchCompanyInfo() -> AnyPublisher<Company, ClientError> {
    let url = URL(string: "https://api.spacexdata.com/v4/company")!

    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: Company.self, decoder: JSONDecoder())
      .mapError { e in ClientError(message: e.localizedDescription) }
      .eraseToAnyPublisher()
  }

  func fetchLaunches() -> AnyPublisher<[Launch], ClientError> {
    let url = URL(string: "https://api.spacexdata.com/v4/launches")!

    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: [Launch].self, decoder: jsonDecoder)
      .mapError { e in ClientError(message: e.localizedDescription) }
      .eraseToAnyPublisher()
  }

  func fetchRockets() -> AnyPublisher<[String : Rocket], ClientError> {
    let url = URL(string: "https://api.spacexdata.com/v4/rockets")!

    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: [Rocket].self, decoder: jsonDecoder)
      .map { $0.keyedDictionary() }
      .mapError { e in ClientError(message: e.localizedDescription) }
      .eraseToAnyPublisher()
  }
}

// MARK: - Private helpers

private extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

private let jsonDecoder: JSONDecoder = {
  let d = JSONDecoder()
  d.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
  return d
}()
