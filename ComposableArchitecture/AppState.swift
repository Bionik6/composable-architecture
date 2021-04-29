//
//  AppState.swift
//  ComposableArchitecture
//
//  Created by Ibrahima Ciss on 29/04/2021.
//

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
    self.value = initialValue
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

enum FavoritesPrimeAction {
  case deleteFavoritePrimes(IndexSet)
}

enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case deleteFavoritePrimeTapped
}

// (A, B) -> A <==> (inout A, B) -> Void
func appReducer(state: inout AppState, action: AppAction) {
  switch action {
    case .counter(.incrTapped):
      state.count += 1
    
    case .counter(.decrTapped):
      state.count += 1
    
    case .primeModal(.saveFavoritePrimeTapped):
      state.favoritePrimes.append(state.count)
      state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
      
    case .primeModal(.deleteFavoritePrimeTapped):
      state.favoritePrimes.removeAll { $0 == state.count }
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
      
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet { state.favoritePrimes.remove(at: index) }
  }
}
