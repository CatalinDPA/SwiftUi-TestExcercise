//
//  RecipeDetail.swift
//  BetterRecipe
//
//  Created by Catalin Posedaru on 15/12/25.
//

import SwiftUI
import SwiftData

struct RecipeDetail: View {
    @Bindable var recipe: Recipe
    @State var editRecipe: Bool
    @State var newRecipe: Bool


    var body: some View {
        NavigationStack {
            if editRecipe {
                EditView(recipe: recipe, newRecipe: $newRecipe)
                    .modelContainer(for: Recipe.self)
                    .background(.softGreen.opacity(0.3))
            } else {
                NormalRecipeDetail(recipe: recipe)
                    .modelContainer(for: Recipe.self)
                    .background(.softGreen.opacity(0.3))
            }

        }
        .toolbar {
            if !newRecipe {
                ToolbarItem {
                    withAnimation(.easeInOut) {
                        Toggle("Edit recipe", isOn: $editRecipe)
                            .toggleStyle(.switch)
                            .padding()
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    RecipeDetail(recipe: Recipe(
        title: "Palomitas de maiz de maiz de maiz de maiz",
       ingredients: ["Maiz", "a"],
       instructions: "En el microondas si es de microondas, mejor",
        isFavorite: false), editRecipe: false, newRecipe: false)
        .background(.softGreen.opacity(0.3))
}


struct NormalRecipeDetail: View {
    @Bindable var recipe: Recipe
    @State private var showInstructions = false

    var body: some View {
        NavigationStack {
            HStack {
                Text(recipe.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 250)
                    .foregroundColor(.darkerGreen)

                Button("Favorite", systemImage: !recipe.isFavorite ? "star" : "star.fill") {
                    recipe.isFavorite.toggle()
                }
                .transition(.move(edge: .trailing))
                .labelStyle(.iconOnly)
                .foregroundColor(.orangeAccent)
                .buttonStyle(.borderless)
                .font(.largeTitle)
            }

            Rectangle()
                .fill(.principalGreen)
                .frame(height: 2)

            VStack {
                Text("Ingredients")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.darkerGreen)

                List {
                    ForEach(recipe.ingredients, id: \.self) { ingr in
                        Text(ingr)
                            .padding(4)
                            .listRowSeparatorTint(.black)
                            .listRowBackground(Color.darkerGreen.opacity(0.4))
                    }
                }

                .scrollContentBackground(.hidden)
                .scrollDisabled(recipe.ingredients.count < 4)
                .frame(maxHeight: .infinity)
            }
            .padding()

            Rectangle()
                .fill(.principalGreen)
                .frame(height: 2)

            VStack {
                Text("Instructions")
                    .font(.title)
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.darkerGreen)


                Button("View instructions") {
                    showInstructions.toggle()
                }
                .padding()
                .buttonStyle(.glassProminent)
                .tint(.darkerGreen)
            }
            .padding()

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showInstructions) {
            ScrollView {
                if !recipe.instructions.isEmpty {
                    Text(recipe.instructions)
                        .font(.system(size: 22, design: .rounded))
                        .padding(40)
                } else {
                    Text("Looks like there are no instructions for this one, maybe you can add them!")
                        .font(.system(size: 22, design: .rounded))
                        .padding(40)
                }
                Spacer()
            }
            .presentationBackground(.softGreen.opacity(0.7))
        }

    }
}

struct EditView: View {
    @Bindable var recipe: Recipe
    @State private var newIngredient: String = ""
    @Binding var newRecipe: Bool

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private func addIngredient() {
        newIngredient = ""
    }

    private func deleteIngredient(indexes: IndexSet) {
        for index in indexes {
            recipe.ingredients.remove(at: index)
        }
    }

    var body: some View {
        ScrollView {
                HStack {
                    TextField("Add recipe title", text: $recipe.title)
                        .font(.title)
                        .bold()
                        .padding(12)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                }
                .padding()

            Divider()


            VStack {
                Text("Ingredients")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.darkerGreen)

                TextField("Add ingredient", text: $newIngredient)
                    .padding()
                    .textFieldStyle(.roundedBorder)

                Button("Add ingredient", systemImage: "plus") {
                    if newIngredient.count > 0 {
                        withAnimation(.smooth(duration: 0.3)) {
                            recipe.ingredients.append(newIngredient)
                        }
                    }
                    newIngredient = ""

                }
                List {
                    ForEach(recipe.ingredients, id: \.self) { ingr in
                        Text(ingr)
                            .padding(4)
                            .listRowSeparatorTint(.black)
                            .listRowBackground(Color.darkerGreen.opacity(0.4))
                    }
                    .onDelete(perform: deleteIngredient(indexes:))
                }
                .scrollContentBackground(.hidden)
                .scrollDisabled(recipe.ingredients.count < 0 )
                .frame(maxHeight: .infinity)
            }
            .frame(height: 500)
            .padding()

            Divider()

            VStack {
                Text("Instructions")
                    .font(.title)
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.darkerGreen)
                TextField(
                    "Add the intructions",
                    text: $recipe.instructions,
                    axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 20))
                .padding()
            }
            .padding()
            Spacer()
        }
        .toolbar {
            if newRecipe {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        context.insert(recipe)
                        do {
                            try context.save()
                        } catch {
                            fatalError("Error saving context")
                        }
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
