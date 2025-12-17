//
//  File.swift
//  BetterRecipe
//
//  Created by Catalin Posedaru on 15/12/25.
//

import Foundation
import SwiftData

@Model
class Recipe {
    var title: String
    var ingredients: [String]
    var instructions: String
    var isFavorite: Bool

    init(
        title: String,
        ingredients: [String],
        instructions: String,
        isFavorite: Bool
    ) {
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.isFavorite = isFavorite
    }
}
