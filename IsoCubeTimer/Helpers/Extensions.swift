import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct DeleteButtonView: View {
    
    var index : Int
    var vm : TimerViewModel
    // 1. This variable controls if the popup is visible
    @State private var showingAlert = false

    var body: some View {
        Button(action: {
            // 2. When clicked, just flip the switch to TRUE
            showingAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        // 3. Attach the alert to the button (or any view)
        .alert("Delete Solve?", isPresented: $showingAlert) {
            
            // Button A: The "Do it" button
            Button("Delete", role: .destructive) {
                
                vm.deleteSolve(index: index)
                print("Deleted!")
            }
            
            // Button B: The "Cancel" button (Swift adds this automatically if you want, or you can be explicit)
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
    }
}
