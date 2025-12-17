//
//  RecipeList.swift
//  BetterRecipe
//
//  Created by Catalin Posedaru on 15/12/25.
//

import SwiftUI
import SwiftData

struct RecipeList: View {
    @Environment(\.modelContext) private var context
    @Query private var recipes: [Recipe]
    @State private var isSorted = false
    @State private var newRecipe: Recipe?
    @State private var sortType: String = ""
    @State private var sortedRecipes: [Recipe]?

    init(searchText: String = "") {
        sortedRecipes = nil
        let predicate = #Predicate<Recipe> { recipe in
            searchText.isEmpty || recipe.title
                .localizedStandardContains(searchText)
        }
        _recipes = Query(filter: predicate, sort: \Recipe.title)
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError("Error saving context")
        }
    }
    
    private func deleteRecipe(indexes: IndexSet) {
        for index in indexes {
            context.delete(recipes[index])
        }
        
        if context.hasChanges {
            saveContext()
        }
    }
    
    func addRecipe() {
        self.newRecipe = Recipe(
            title: "",
            ingredients: [],
            instructions: "",
            isFavorite: false
        )
    }

    private func recipeSorter() {
        if sortType == "Favorite" {
            withAnimation(.easeInOut) {
                sortedRecipes = recipes.filter {
                    $0.isFavorite
                }
            }
        } else if (sortType == "Alphabetical"){
            withAnimation(.easeInOut) {
                sortedRecipes = recipes.sorted { first, second in
                    first.title < second.title
                }
            }
        } else {
            withAnimation(.easeInOut) {
                sortedRecipes = recipes
            }
        }
    }


    var body: some View {
        NavigationStack {
            VStack {
                TitleView()

                Rectangle()
                    .fill(.darkerGreen)
                    .frame(height: 2)

                List {
                    ForEach(
                        recipes
                    ) { recipe in
                        NavigationLink(
                            destination: RecipeDetail(
                                recipe: recipe,
                                editRecipe: false,
                                newRecipe: false
                            )
                            .background(.softGreen.opacity(0.7))
                        ) {
                            Text(recipe.title)
                                .font(.system(size: 22))
                            Spacer()
                            Button("Favorite", systemImage: !recipe.isFavorite ? "star" : "star.fill") {
                                recipe.isFavorite.toggle()
                                saveContext()
                            }
                            .font(.title)
                            .labelStyle(.iconOnly)
                            .tint(.orangeAccent)
                            .buttonStyle(.borderless)
                        }
                        .navigationLinkIndicatorVisibility(.hidden)
                    }
                    .onDelete(perform: deleteRecipe(indexes:))
                    .listRowSeparatorTint(.black)
                    .listRowBackground(Color.darkerGreen.opacity(0.4))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem (placement: .topBarLeading) {
                        Button("Add", systemImage: "plus") {
                            addRecipe()
                        }
                    }
                    ToolbarItem (placement: .topBarTrailing) {
                        Button("Sort by...") {
                            isSorted = true
                        }
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                    }
                }
            }
            .background(.softGreen.opacity(0.7))
            .confirmationDialog(
                "Select a sorting method",
                isPresented: $isSorted
            ) {
                Button("Alphabetical") {
                    sortType = "Alphabetical"
                    recipeSorter()
                }
                
                Button("Favorites") {
                    sortType = "Favorite"
                    recipeSorter()
                }
            }
            .sheet(item: $newRecipe) { recipe in
                RecipeDetail(
                    recipe: recipe,
                    editRecipe: true,
                    newRecipe: true)
                .background(.softGreen.opacity(0.7))
            }

        }
    }
}

#Preview {
    RecipeList()
}

struct TitleView: View {
    var body: some View {
        HStack {
            Image(systemName: "pencil.and.list.clipboard.rtl")
                .font(.system(size: 60))
                .padding(8)
            Text("Recipes for you")
                .font(.title)
                .fontWeight(.bold)
                .padding(.trailing, 8)
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke()
        )
        .padding()
        .foregroundColor(.darkerGreen)
    }
}
