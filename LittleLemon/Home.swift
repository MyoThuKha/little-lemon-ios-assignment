import SwiftUI
struct Home: View {
    private let persistence = PersistenceController.shared
    var body: some View {
        TabView {
            NavigationStack { Menu() }
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .tabItem { Label("Menu", systemImage: "fork.knife") }
            NavigationStack { UserProfile() }.tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
