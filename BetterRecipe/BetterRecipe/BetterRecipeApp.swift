//
//  BetterRecipeApp.swift
//  BetterRecipe
//
//  Created by Catalin Posedaru on 15/12/25.
//

import SwiftUI
import SwiftData

@main
struct BetterRecipeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Recipe.self)
        }
    }
}
