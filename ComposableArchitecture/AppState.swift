import Combine
import Foundation


struct AppState {
  var count = 0
  var loggedUser: User?
  var favoritePrimes: [Int] = []
  var activityFeed: [Activity] = []
  
  struct Activity {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }
  
  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}


final class Store<Value, Action>: ObservableObject {
  @Published var value: Value
  let reducer: (inout Value, Action) -> Void
  
  init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
    value = initialValue
    self.reducer = reducer
  }
  
  func send(_ action: Action) {
    reducer(&value, action)
  }
}

enum AppAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
  case favoritePrimes(FavoritesPrimeAction)
}

enum CounterAction {
  case incrTapped
  case decrTapped
}

enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case deleteFavoritePrimeTapped
}

enum FavoritesPrimeAction {
  case deleteFavoritePrimes(IndexSet)
}

// (A, B) -> A <==> (inout A, B) -> Void
//let appReducer = combine(favoritePrimesReducer, combine(counterReducer, primeModalReducer))
let appReducer = combine(pullback(counterReducer, value: \.count),
                         pullback(favoritePrimesReducer, value: \.favoritePrimeState),
                         primeModalReducer)

func counterReducer(state: inout Int, action: AppAction) {
  switch action {
    case .counter(.incrTapped):
      state += 1
    case .counter(.decrTapped):
      state += 1
    default: break
  }
}

extension AppState { 
  var favoritePrimeState: FavoritePrimeState {
    get { FavoritePrimeState(favoritePrimes: favoritePrimes, activityFeed: activityFeed) }
    set { favoritePrimes = newValue.favoritePrimes; activityFeed = newValue.activityFeed }
  }
}

struct FavoritePrimeState { 
  var favoritePrimes: [Int]
  var activityFeed: [AppState.Activity]
}

func favoritePrimesReducer(state: inout FavoritePrimeState, action: AppAction) {
  switch action {
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet { state.favoritePrimes.remove(at: index) }
    default: break
  }
}

func primeModalReducer(state: inout AppState, action: AppAction) {
  switch action {
    case .primeModal(.saveFavoritePrimeTapped):
      state.favoritePrimes.append(state.count)
      state.activityFeed.append(.init(timestamp: Date(),
                                      type: .addedFavoritePrime(state.count)))
      
    case .primeModal(.deleteFavoritePrimeTapped):
      state.favoritePrimes.removeAll { $0 == state.count }
      state.activityFeed.append(.init(timestamp: Date(),
                                      type: .removedFavoritePrime(state.count)))
      
    default: break
  }
}


func combine<Value, Action>(_ first: @escaping (inout Value, Action) -> Void,
                            _ second: @escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
  return { (value, action) -> Void in
    first(&value, action)
    second(&value, action)
  }
}

func combine<Value, Action>(_ reducers: (inout Value, Action) -> Void...) -> (inout Value, Action) -> Void {
  return { (value, action) -> Void in
    for reducer in reducers {
      reducer(&value, action)
    }
  }
}


func pullback<LocalValue, GlobalValue, Action>(_ reducer: @escaping (inout LocalValue, Action) -> Void,
                                               value: WritableKeyPath<GlobalValue, LocalValue>)
-> (inout GlobalValue, Action) -> Void {
  return { globalValue, action in
    reducer(&globalValue[keyPath: value], action)
  }
}
