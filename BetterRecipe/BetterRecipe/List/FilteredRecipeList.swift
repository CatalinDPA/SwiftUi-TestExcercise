//
//  FilteredRecipeList.swift
//  BetterRecipe
//
//  Created by Catalin Posedaru on 16/12/25.
//

import SwiftUI
import SwiftData

struct FilteredRecipeList: View {
    @State private var searchText: String = ""

    var body: some View {
        RecipeList(searchText: searchText)
        .searchable(text: $searchText, prompt: "Search your new favorite recipe")

    }
}

#Preview {
    FilteredRecipeList()
}
