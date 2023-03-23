import SwiftUI

struct FilterBarView: View {
    let filterTitles: [String]
    @Binding var selectedFilter: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)

            HStack {
                ForEach(filterTitles.indices, id: \.self) { index in
                    AdButton(onButtonAction: {
                        selectedFilter = index
                    }) {
                        Text(filterTitles[index])
                            .font(.system(size: 16))
                            .foregroundColor(selectedFilter == index ? .white : Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == index ? Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)) : Color.white)
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
        FilterBarView(filterTitles: ["Daily", "Monthly", "Yearly", "Job", "Client"], selectedFilter: .constant(0))
    }
}
