import CoreData
import SwiftUI

struct Menu: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State private var searchText = ""
  @State private var category = ""
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var showProfile = false
  @FocusState private var searchFocused: Bool

  var body: some View {
    FetchedObjects(predicate: buildPredicate(), sortDescriptors: buildSortDescriptors()) {
      (dishes: [Dish]) in
      List {
        HStack {
          Image("Logo").resizable().scaledToFit().frame(height: 42)
            .accessibilityLabel("Little Lemon")
          Spacer()
          Button {
            showProfile = true
          } label: {
            Image("Profile").resizable().scaledToFit()
              .frame(width: 44, height: 44).clipShape(Circle())
          }.buttonStyle(.borderless).accessibilityLabel("Open profile")
        }
        .padding(.vertical, 8)
        .listRowSeparator(.hidden)

        VStack(spacing: 0) {
          RestaurantHeader()
          HStack {
            Image(systemName: "magnifyingglass").accessibilityHidden(true)
            TextField("Search menu", text: $searchText)
              .accessibilityIdentifier("searchMenu")
              .focused($searchFocused)
              .submitLabel(.search)
              .onSubmit { searchFocused = false }
            if !searchText.isEmpty {
              Button {
                searchText = ""
              } label: {
                Image(systemName: "xmark.circle.fill")
              }
              .accessibilityLabel("Clear search")
            }
          }
          .padding(12).background(.background, in: RoundedRectangle(cornerRadius: 10))
          .padding([.horizontal, .bottom])
        }
        .background(Brand.green)
        .listRowInsets(EdgeInsets()).listRowSeparator(.hidden)

        VStack(alignment: .leading, spacing: 12) {
          Text("ORDER FOR DELIVERY").font(.headline)
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(["", "starters", "mains", "desserts"], id: \.self) { value in
                Button(value.isEmpty ? "All" : value.capitalized) {
                  category = value
                  searchFocused = false
                }
                .buttonStyle(.borderedProminent)
                .tint(category == value ? Brand.green : .gray)
                .accessibilityAddTraits(category == value ? .isSelected : [])
              }
            }
          }
        }
        .padding(.vertical, 8).listRowSeparator(.hidden)

        if isLoading { ProgressView("Refreshing menu…") }
        if let errorMessage {
          HStack {
            Text(errorMessage).font(.caption)
            Button("Retry") { Task { await getMenuData() } }
          }
        }
        if dishes.isEmpty && !isLoading {
          VStack(alignment: .leading, spacing: 10) {
            Text("No dishes to show").font(.headline)
            Text("Try another search, category, or refresh.").foregroundStyle(.secondary)
          }.padding(.vertical)
        } else {
          ForEach(dishes) { dish in
            NavigationLink {
              DishDetails(dish: dish)
            } label: {
              DishRow(dish: dish)
            }
          }
        }
      }
      .listStyle(.plain)
      .scrollDismissesKeyboard(.interactively)
      .refreshable { await getMenuData() }
    }
    .navigationTitle("Menu").navigationBarTitleDisplayMode(.inline)
    .navigationDestination(isPresented: $showProfile) { UserProfile() }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          Task { await getMenuData() }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .accessibilityLabel("Refresh menu").disabled(isLoading)
      }
    }
    .task { await getMenuData() }
  }
  func buildSortDescriptors() -> [NSSortDescriptor] { MenuQuery.sortDescriptors() }
  func buildPredicate() -> NSPredicate {
    MenuQuery.predicate(searchText: searchText, category: category)
  }
  @MainActor func getMenuData() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      let items = try await MenuData.fetch()
      try await viewContext.perform { try MenuData.save(items, in: viewContext) }
    } catch is CancellationError {} catch {
      errorMessage = "Could not refresh. Any saved menu is still available."
    }
  }
}
struct DishRow: View {
  @ObservedObject var dish: Dish
  var body: some View {
    HStack(spacing: 14) {
      VStack(alignment: .leading, spacing: 6) {
        Text(dish.title).font(.headline)
        Text(dish.details).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
        Text("$" + dish.price).font(.subheadline.bold()).foregroundStyle(Brand.green)
      }
      Spacer(minLength: 0)
      DishImage(url: dish.image).frame(width: 80, height: 80).clipped().cornerRadius(12)
    }.padding(.vertical, 8)
  }
}
struct DishImage: View {
  let url: String
  var body: some View {
    AsyncImage(url: URL(string: url)) { phase in
      if let image = phase.image {
        image.resizable().scaledToFill()
      } else if phase.error != nil {
        Image(systemName: "photo").resizable().scaledToFit().padding(20).foregroundStyle(.secondary)
      } else {
        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }.accessibilityHidden(true)
  }
}
struct DishDetails: View {
  @ObservedObject var dish: Dish
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        DishImage(url: dish.image).frame(height: 240).clipped().cornerRadius(16)
        Text(dish.title).font(.largeTitle.bold())
        Text(dish.details)
        Text("$" + dish.price).font(.title2.bold()).foregroundStyle(Brand.green)
        Text(
          "Menu preview for the capstone project. Ordering and payments are outside this exercise."
        ).font(.footnote).foregroundStyle(.secondary)
      }.padding()
    }.navigationTitle(dish.title).navigationBarTitleDisplayMode(.inline)
  }
}
