import Foundation

enum Remote<T, RemoteError: Error> {
  case notRequested
  case fetching
  case success(T)
  case error(RemoteError)
}
