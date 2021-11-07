import Foundation

struct Company: Equatable {
  var name: String
  var founder: String
  var founded: Int
  var employees: Int
  var launchSites: Int
  var valuation: Int
}

extension Company: Decodable {
  static let yearFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .none
    return nf
  }()

  var yearString: String {
    Company.yearFormatter.string(from: NSNumber(value: founded))!
  }

  enum CodingKeys: String, CodingKey {
    case name
    case founder
    case founded
    case employees
    case launchSites = "launch_sites"
    case valuation
  }
}
