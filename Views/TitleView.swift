import SwiftUI

// First view
struct TitleView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    Image("Logo-white")
                        .resizable()
                        .frame(width: 330, height: 300)
                    
                    Text("AfterShift Alert")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundStyle(Color.nightAccent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Card {
                        Text("See how your sleep, circadian rhythm, attention, and commute affect alertness after a night shift. Learn how safe it is to drive home and what actions can reduce your risk.")
                            .font(.title3)
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                                
                    NavigationLink {
                        IntroView()
                    } label: {
                        PrimaryButtonStyleView(title: "Start")
                    }
                    .padding()
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
    }
}
