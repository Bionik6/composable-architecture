//
//  ContentView.swift
//  ComposableArchitecture
//
//  Created by Ibrahima Ciss on 19/02/2021.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink("Counter Demo", destination: CounterView(store: store))
        NavigationLink("Favorite Prime", destination: FavoritePrimeView(store: store))
      }.navigationTitle("State Management")
    }
  }
}



struct CounterView: View {
  @State var alertNthPrime: Int?
  @ObservedObject var store: Store<AppState, AppAction>
  @State var isPrimeModalShown: Bool = false
  @State var isNthPrimeButtonDisabled = false
  
  var body: some View {
    VStack {
      HStack {
        Button("-") { store.value.count -= 1 }
        Text("\(store.value.count)")
        Button("+") { store.value.count += 1 }
      }
      Button("Is this prime?") { isPrimeModalShown.toggle() }
      
      Button("What is the \(ordinal(store.value.count)) prime?", action: nthPrimeButtonAction)
        .disabled(isNthPrimeButtonDisabled)
    }
    .font(.title)
    .navigationTitle("Counter Demo")
    .sheet(isPresented: $isPrimeModalShown) { IsPrimeModalView(store: store) }
    .alert(item: $alertNthPrime) { n -> Alert in
      Alert(title: Text("The \(ordinal(store.value.count)) prime is \(n)"), dismissButton: .default(Text("Ok")))
    }
  }
  
  func nthPrimeButtonAction() {
    isNthPrimeButtonDisabled = true
    nthPrime(store.value.count) { prime in
      alertNthPrime = prime
      isNthPrimeButtonDisabled = false
    }
  }
}



struct IsPrimeModalView: View {
  
  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    VStack {
      if isPrime(store.value.count) {
        Text("\(store.value.count) is prime 🎉🎊")
        if(store.value.favoritePrimes.contains(store.value.count)) {
          Button("Remove from favorite primes") { store.send(.primeModal(.deleteFavoritePrimeTapped)) }
        } else {
          Button("Add to favorite primes") { store.send(.primeModal(.saveFavoritePrimeTapped)) }
        }
      } else {
        Text("\(store.value.count) is not prime 😞")
      }
    }
  }
  
}



struct FavoritePrimeView: View {

  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    List {
      ForEach(store.value.favoritePrimes) { prime in
        Text("\(prime)")
      }
      .onDelete { store.send(.favoritePrimes(.deleteFavoritePrimes($0))) }
    }
    .navigationTitle(Text("Favorite Primes"))
  }
  
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: Store(initialValue: AppState(), reducer: appReducer))
  }
}
