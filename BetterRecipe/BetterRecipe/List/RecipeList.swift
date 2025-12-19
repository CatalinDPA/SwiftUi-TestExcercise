import SwiftUI
import SwiftData

struct RecipeList: View {
    @Environment(\.modelContext) private var context
    @Query private var recipes: [Recipe]
    @State private var isSorted = false
    @State private var newRecipe: Recipe?
    @State private var sortType: String = ""

    init(searchText: String = "") {
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
        var toDelete: Recipe?
        for index in indexes {
            toDelete = sortedRecipes[index]
        }
        if let toDelete = toDelete {
            for index in 0..<recipes.count {
                if recipes[index].title == toDelete.title {
                    context.delete(recipes[index])
                }
            }
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

    var sortedRecipes: [Recipe] {
        if sortType == "Favorite" {
            withAnimation(.easeInOut) {
                return recipes.filter {
                    $0.isFavorite
                }
            }
        } else if (sortType == "Alphabetical"){
            withAnimation(.easeInOut) {
                return recipes.sorted { first, second in
                    first.title < second.title
                }
            }
        } else {
            withAnimation(.easeInOut) {
                return recipes
            }
        }
    }


    var body: some View {
        NavigationStack {
            VStack {
                TitleView()

                listView

                Rectangle()
                    .fill(.darkerGreen)
                    .frame(height: 2)

                            }
            .background(.softGreen.opacity(0.7))
            .confirmationDialog(
                "Select a sorting method",
                isPresented: $isSorted
            ) {
                Button("Alphabetical") {
                    sortType = "Alphabetical"
                }

                Button("Favorites") {
                    sortType = "Favorite"
                }
            }
            .sheet(item: $newRecipe) { recipe in
                RecipeDetail(
                    recipe: recipe,
                    state: .creating)
                .background(.softGreen.opacity(0.7))
            }

        }
    }

    var listView: some View {
        List {
            ForEach(
                sortedRecipes
            ) { recipe in
                NavigationLink(
                    destination: RecipeDetail(
                        recipe: recipe,
                        state: .reading
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
