import SwiftUI

struct ModernCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
    }
}

struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
    }
}

extension View {
    func modernCard() -> some View {
        modifier(ModernCardStyle())
    }
    
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }
}
