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
  @Published var favoritePrimes: [Int] = []
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


private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}

struct CounterView: View {
  
  @State var alertNthPrime: Int?
  @ObservedObject var state: AppState
  @State var isPrimeModalShown: Bool = false
  
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
      Button(action: {
        nthPrime(state.count) { prime in
          alertNthPrime = prime
        }
      }, label: {
        Text("What is the \(ordinal(state.count)) prime?")
      })
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
}

extension Int: Identifiable {
  public var id: String {
    return "\(self)"
  }
  
}

private func isPrime(_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

struct IsPrimeModalView: View {
  
  @ObservedObject var state: AppState
  
  var body: some View {
    VStack {
      if isPrime(state.count) {
          Text("\(state.count) is prime 🎉🎊")
        if(state.favoritePrimes.contains(state.count)) {
          Button(action: { state.favoritePrimes.removeAll { $0 == state.count } }, label: { 
            Text("Remove from favorite primes")
          })
        } else {
          Button(action: { state.favoritePrimes.append(state.count) }, label: {
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
