import SwiftUI
import SwiftData

struct RecipeDetail: View {
    @Bindable var recipe: Recipe
    @State private var showInstructions = false
    @State private var newIngredient: String = ""
    @State var state: RecipeDetailState
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

    var title: some View {
        HStack {
            if state == .reading {
                Text(recipe.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 250)
                    .foregroundColor(.darkerGreen)

                Button("Favorite", systemImage: !recipe.isFavorite ? "star" : "star.fill") {
                    recipe.isFavorite.toggle()
                }
                .labelStyle(.iconOnly)
                .foregroundColor(.orangeAccent)
                .buttonStyle(.borderless)
                .font(.largeTitle)
            } else {
                TextField("Add recipe title", text: $recipe.title)
                    .font(.title)
                    .bold()
                    .padding(12)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var ingredients: some View {
        VStack {
            Text("Ingredients")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.darkerGreen)
            if state == .reading {
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
            } else {
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
                .frame(height: 200)
                .scrollContentBackground(.hidden)
            }
        }

    }


        var instructions: some View {
            VStack {
                Text("Instructions")
                    .font(.title)
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.darkerGreen)

                if state == .reading {
                    Button("View instructions") {
                        showInstructions.toggle()
                    }
                    .padding()
                    .buttonStyle(.glassProminent)
                    .tint(.darkerGreen)
                } else {
                    TextField(
                        "Add the intructions",
                        text: $recipe.instructions,
                        axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 20))
                    .padding()
                }
            }
        }

    var body: some View {
        NavigationStack {
            title

            Rectangle()
                .fill(.principalGreen)
                .frame(height: 2)

            ingredients

            Rectangle()
                .fill(.principalGreen)
                .frame(height: 2)

            instructions

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
            .toolbar {
                if state == .reading || state == .editing {
                    ToolbarItem {
                        withAnimation(.easeInOut) {
                            Button("Edit recipe") {
                                if state == .reading {
                                    state = .editing
                                } else {
                                    state = .reading
                                }
                            }
                            .padding()
                        }
                    }
                }
                if state == .creating {
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

#Preview {
    RecipeDetail(recipe: Recipe(
        title: "Palomitas de maiz de maiz de maiz de maiz",
       ingredients: ["Maiz", "a"],
       instructions: "En el microondas si es de microondas, mejor",
        isFavorite: false), state: .editing)
        .background(.softGreen.opacity(0.3))
}



