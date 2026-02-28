import SwiftUI

// Card layout
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content
                .padding(24)
                .glassEffect(in: .rect(cornerRadius: 20))
            
        } else {
      
            content
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                )
        }
    }
}


// Card layout for tests
struct TestCard: View {
    var test: AlertnessTest
    var completedTests: [AlertnessTestType: Double]
    @Binding var showingPreTest: AlertnessTest?

    var body: some View {
        if #available(iOS 26.0, *) {
            HStack {
                Image(systemName: test.symbol)
                    .font(.largeTitle)
                    .foregroundStyle(Color.nightAccent)
                    .padding()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(test.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("Measures: \(test.measures)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text("Duration: \(test.duration)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                if let score = completedTests[test.type] {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.safe)
                        Text("\(score, specifier: "%.0f")%")
                            .font(.caption)
                            .foregroundStyle(Color.secondary.opacity(0.7))
                    }
                } else {
                    Button {
                        showingPreTest = test
                    } label: {
                        PrimaryButtonStyleView(title: "Take Test", fullWidth: false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .glassEffect(in: .rect(cornerRadius: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } else {
            Card {
                HStack {
                    Image(systemName: test.symbol)
                        .font(.largeTitle)
                        .foregroundStyle(Color.nightAccent)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(test.name)
                            .font(.title3.bold())
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Text("Measures: \(test.measures)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Text("Duration: \(test.duration)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if let score = completedTests[test.type] {
                        VStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.safe)
                            Text("\(score, specifier: "%.0f")%")
                                .font(.caption)
                                .foregroundStyle(Color.secondary.opacity(0.7))
                        }
                    } else {
                        Button {
                            showingPreTest = test
                        } label: {
                            PrimaryButtonStyleView(title: "Take Test")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}

