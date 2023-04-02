import SwiftUI

struct FilterBarView: View {
    let filterTitles: [String]
    @Binding var selectedFilter: Int
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(colorScheme == .dark ? .black : .white)

            HStack {
                ForEach(filterTitles.indices, id: \.self) { index in
                    AdButton(onButtonAction: {
                        selectedFilter = index
                    }) {
                        Text(filterTitles[index])
                            .font(.system(size: 14))
                            .foregroundColor(selectedFilter == index ? .white : (colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1))))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == index ? Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)) : (colorScheme == .dark ? Color.black : Color.white))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FilterBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterBarView(filterTitles: ["Daily", "Monthly", "Yearly", "Job", "Client"], selectedFilter: .constant(0))
                .previewDisplayName("Light Mode")
            
            FilterBarView(filterTitles: ["Daily", "Monthly", "Yearly", "Job", "Client"], selectedFilter: .constant(0))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
