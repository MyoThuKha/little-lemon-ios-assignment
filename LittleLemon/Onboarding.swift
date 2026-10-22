import SwiftUI

struct Onboarding: View {
  private enum Step: Hashable { case lastName, email, review }

  @AppStorage("isLoggedIn") private var isLoggedIn = false
  @State private var firstName = ""
  @State private var lastName = ""
  @State private var email = ""
  @State private var path: [Step] = []

  var body: some View {
    if isLoggedIn {
      Home()
    } else {
      NavigationStack(path: $path) {
        page(number: 1)
          .navigationTitle("Registration")
          .navigationDestination(for: Step.self) { step in
            page(number: step == .lastName ? 2 : step == .email ? 3 : 4)
              .navigationTitle(step == .lastName ? "Your last name" : step == .email ? "Your email" : "Review profile")
              .navigationBarBackButtonHidden()
              .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                  Button {
                    path.removeLast()
                  } label: {
                    Label("Back", systemImage: "chevron.left")
                  }
                }
              }
          }
      }
      .onAppear {
        // A logout starts a fresh registration, without retaining the old form.
        firstName = ""
        lastName = ""
        email = ""
        path = []
      }
    }
  }

  private func page(number: Int) -> some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Image("Logo")
            .resizable().scaledToFit().frame(height: 44)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Little Lemon")
          Text("Step \(number) of 4")
            .font(.subheadline.weight(.semibold)).foregroundStyle(Brand.green)
          if number == 1 {
            Text("Welcome to Little Lemon").font(.title2.bold())
            Text("Let’s start with your first name.").foregroundStyle(.secondary)
            TextField("First name", text: $firstName)
              .textContentType(.givenName).accessibilityIdentifier("firstName")
          } else if number == 2 {
            Text("What is your last name?").font(.largeTitle.bold())
            TextField("Last name", text: $lastName)
              .textContentType(.familyName).accessibilityIdentifier("lastName")
          } else if number == 3 {
            Text("How can we reach you?").font(.largeTitle.bold())
            Text("Add an email address for your local profile.").foregroundStyle(.secondary)
            TextField("Email", text: $email)
              .textContentType(.emailAddress).keyboardType(.emailAddress)
              .textInputAutocapitalization(.never).autocorrectionDisabled()
              .accessibilityIdentifier("email")
            Text("Use a complete address, such as name@example.com.")
              .font(.footnote).foregroundStyle(.secondary)
          } else {
            Text("Ready to explore the menu?").font(.largeTitle.bold())
            LabeledContent(
              "First name", value: firstName.trimmingCharacters(in: .whitespacesAndNewlines))
            LabeledContent(
              "Last name", value: lastName.trimmingCharacters(in: .whitespacesAndNewlines))
            LabeledContent("Email", value: email.trimmingCharacters(in: .whitespacesAndNewlines))
            Text(
              "Your profile is saved on this device. You can update it from Profile or clear it by logging out."
            )
            .font(.subheadline).foregroundStyle(.secondary)
          }
        }
        .padding(24)
        .textFieldStyle(.roundedBorder)
      }
      .scrollDismissesKeyboard(.interactively)
      Button {
        if number == 1 {
          path.append(.lastName)
        } else if number == 2 {
          path.append(.email)
        } else if number == 3 {
          path.append(.review)
        } else {
          register()
        }
      } label: {
        Text(number == 4 ? "Register" : "Next").frame(maxWidth: .infinity)
      }
      .accessibilityIdentifier(number == 4 ? "register" : "next")
      .buttonStyle(.borderedProminent).controlSize(.large)
      .disabled(number == 1 ? firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : number == 2 ? !hasName : !validProfile)
      .padding().background(.regularMaterial)
    }
    .navigationBarTitleDisplayMode(.inline)
  }

  private var hasName: Bool {
    !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private var validProfile: Bool {
    ProfileValidation.isValid(
      firstName: firstName, lastName: lastName,
      email: email.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  private func register() {
    guard validProfile else { return }
    let defaults = UserDefaults.standard
    defaults.set(firstName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "firstName")
    defaults.set(lastName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "lastName")
    defaults.set(email.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "email")
    isLoggedIn = true
  }
}
