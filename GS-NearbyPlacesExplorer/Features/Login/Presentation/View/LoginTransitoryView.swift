import SwiftUI

/// A transitory view displayed immediately after a successful authentication.
///
/// It visually confirms the user's identity by displaying their profile image
/// and name before transitioning to the main application flow.
struct LoginTransitoryView: View {
    let profile: LoginEntity?
    
    var body: some View {
        VStack(spacing: 24) {
            if let imageURL = profile?.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            if let name = profile?.name {
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#if DEBUG
#Preview {
    LoginTransitoryView(profile: LoginEntity(id: "1", name: "Carlos Lopez", email: "carlos@example.com", profileImageURL: nil))
}
#endif