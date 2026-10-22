import SwiftUI
@main
struct LittleLemonApp: App {
    var body: some Scene { WindowGroup { Onboarding().tint(Brand.green) } }
}
enum Brand {
    static let green = Color(red: 73/255, green: 94/255, blue: 87/255)
    static let yellow = Color(red: 244/255, green: 206/255, blue: 20/255)
}
struct RestaurantHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Little Lemon").font(.largeTitle.bold()).foregroundStyle(Brand.yellow)
                Text("Chicago").font(.title2).foregroundStyle(.white)
                Text("We are a family-owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                    .font(.subheadline).foregroundStyle(.white)
            }
            Image("Hero").resizable().scaledToFill().frame(width: 100, height: 130).clipped().cornerRadius(16).accessibilityHidden(true)
        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(Brand.green)
    }
}
