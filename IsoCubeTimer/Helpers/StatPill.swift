import SwiftUI

struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color.opacity(0.8))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

// You can keep a preview here to test just this button!
#Preview {
    StatPill(label: "TEST", value: "10.00", color: .cyan)
        .padding()
        .background(Color.black)
}
