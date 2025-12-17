import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        FilteredRecipeList()
            .background(.softGreen.opacity(0.7))

    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self)
}
