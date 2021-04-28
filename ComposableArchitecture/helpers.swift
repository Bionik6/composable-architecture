//
//  helpers.swift
//  ComposableArchitecture
//
//  Created by Ibrahima Ciss on 29/03/2021.
//

import Foundation

extension Int: Identifiable {
  public var id: String {
    return "\(self)"
  }
}


func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}


func isPrime(_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}
