//
//  ContentView.swift
//  ComposableArchitecture
//
//  Created by Ibrahima Ciss on 19/02/2021.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
  var count = 0 {
    willSet { objectWillChange.send() }
  }
  
  var objectWillChange = PassthroughSubject<Void, Never>()
}

struct ContentView: View {
  @ObservedObject var state: AppState
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: state)) {
          Text("Counter Demo")
        }
        NavigationLink(destination: EmptyView()) {
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
  
  @ObservedObject var state: AppState
  
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
      Button(action: { }, label: {
        Text("Is this prime?")
      })
      Button(action: {}, label: {
        Text("What is the \(ordinal(state.count)) prime?")
      })
    }
    .font(.title)
    .navigationTitle("Counter Demo")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(state: AppState())
  }
}
