import SwiftUI

struct TitleView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Title Of The App")
                
                Text("Given a night-shift worker’s circadian state, sleep debt, attention performance, and commute context, how safe is it to drive right now, and what actions most meaningfully reduce that risk and improve alertness?")
                
                NavigationLink {
                    InputView()
                } label: {
                    Text("Start")
                }

            }
        }
    }
}
