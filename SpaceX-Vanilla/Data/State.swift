import Foundation

enum State<T, StateError: Error> {
  case idle
  case loading
  case success(T)
  case error(StateError)
}
