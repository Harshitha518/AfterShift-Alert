
import SwiftUI

struct PrimaryButtonStyleView: View {
    let title: String
    var fullWidth = true
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.nightAccent)
            )
            .foregroundStyle(.white)
    }
}

struct SecondaryButtonStyleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.nightAccent, lineWidth: 2)
            )
            .foregroundStyle(Color.nightAccent)
    }
}
