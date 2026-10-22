import SwiftUI

struct UserProfile: View {
  @AppStorage("firstName") private var firstName = ""
  @AppStorage("lastName") private var lastName = ""
  @AppStorage("email") private var email = ""
  @AppStorage("isLoggedIn") private var isLoggedIn = false
  var body: some View {
    Form {
      Section {
        Image("Profile").resizable().scaledToFit().frame(width: 80, height: 80).accessibilityHidden(
          true)
        TextField("First name", text: $firstName).accessibilityIdentifier("profileFirstName")
        TextField("Last name", text: $lastName).accessibilityIdentifier("profileLastName")
        TextField("Email", text: $email).accessibilityIdentifier("profileEmail").keyboardType(
          .emailAddress
        ).textInputAutocapitalization(.never).autocorrectionDisabled()
      } header: {
        Text("Personal information")
      } footer: {
        Text("Changes save automatically on this device.")
      }
      Section {
        Button("Log out", role: .destructive) {
          firstName = ""
          lastName = ""
          email = ""
          isLoggedIn = false
        }
      }
    }.navigationTitle("My profile")
  }
}
