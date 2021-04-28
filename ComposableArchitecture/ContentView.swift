//
//  ContentView.swift
//  ComposableArchitecture
//
//  Created by Ibrahima Ciss on 19/02/2021.
//

import SwiftUI
import Combine


class AppState: ObservableObject {
  @Published var count = 0
  @Published var loggedUser: User?
  @Published var favoritePrimes: [Int] = []
  @Published var activityFeed: [Activity] = []
  
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

extension AppState {
  func addFavoritePrime() {
    favoritePrimes.append(count)
    activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(count)))
  }
  
  func removeFavoritePrime(_ prime: Int) {
    favoritePrimes.removeAll(where: { $0 == prime })
    activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
  }
  
  func removeFavoritePrime() {
    removeFavoritePrime(count)
  }
  
  func removeFavoritePrimes(at indexSet: IndexSet) {
    for index in indexSet { removeFavoritePrime(favoritePrimes[index]) }
  }
}



struct ContentView: View {
  @ObservedObject var state: AppState
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: state)) {
          Text("Counter Demo")
        }
        NavigationLink(destination: FavoritePrimeView(state: state)) {
          Text("Favorite Prime")
        }
      }.navigationTitle("State Management")
    }
  }
}



struct CounterView: View {
  
  @State var alertNthPrime: Int?
  @ObservedObject var state: AppState
  @State var isPrimeModalShown: Bool = false
  @State var isNthPrimeButtonDisabled = false
  
  var body: some View {
    VStack {
      HStack {
        Button(action: { state.count -= 1 }, label: {
          Text("-")
        })
        Text("\(state.count)")
        Button(action: { state.count += 1 }, label: {
          Text("+")
        })
      }
      Button(action: { isPrimeModalShown.toggle() }, label: {
        Text("Is this prime?")
      })
      Button(action: nthPrimeButtonAction) {
        Text("What is the \(ordinal(state.count)) prime?")
      }.disabled(isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationTitle("Counter Demo")
    .sheet(isPresented: $isPrimeModalShown, content: {
      IsPrimeModalView(state: state)
    })
    .alert(item: $alertNthPrime) { n -> Alert in
      Alert(title: Text("The \(ordinal(state.count)) prime is \(n)"), dismissButton: .default(Text("Ok")))
    }
    
  }
  
  func nthPrimeButtonAction() {
    isNthPrimeButtonDisabled = true
    nthPrime(state.count) { prime in
      alertNthPrime = prime
      isNthPrimeButtonDisabled = false
    }
  }
}



struct IsPrimeModalView: View {
  
  @ObservedObject var state: AppState
  
  var body: some View {
    VStack {
      if isPrime(state.count) {
        Text("\(state.count) is prime 🎉🎊")
        if(state.favoritePrimes.contains(state.count)) {
          Button(action: {
            state.favoritePrimes.removeAll { $0 == state.count }
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
          }, label: {
            Text("Remove from favorite primes")
          })
        } else {
          Button(action: {
            state.favoritePrimes.append(state.count)
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
          }, label: {
            Text("Add to favorite primes")
          })
        }
      } else {
        Text("\(state.count) is not prime 😞")
      }
    }
  }
}



struct FavoritePrimeView: View {

  @ObservedObject var state: AppState
  
  var body: some View {
    List {
      ForEach(state.favoritePrimes) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        for index in indexSet { state.favoritePrimes.remove(at: index) }
      }
    }
    .navigationTitle(Text("Favorite Primes"))
  }
  
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(state: AppState())
  }
}
