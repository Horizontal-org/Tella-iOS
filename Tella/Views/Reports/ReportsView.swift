//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct ReportsView: View {
    @State var title: String = ""
    @State var description: String = ""
    @State var selecetedCell = Pages.new
    
    enum Pages: Hashable {
       case new
       case draft
       case outbox
       case sent
    }
    
    init() {
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    PageView(selectedOption: self.$selecetedCell)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding([.leading, .trailing], 10)
                    VStack {
                        switch self.selecetedCell {
                        case .new:
                            NewReportView(title: self.$title, description: self.$description)
                        case .draft:
                            VStack(alignment: .leading) {
                                Text("Draft")
                            }
                        case .outbox:
                            VStack(alignment: .leading) {
                                Text("Outbox")
                            }
                        case .sent:
                            VStack(alignment: .leading) {
                                Text("Sent")
                            }
                        }
                    }
                }
                .background(Color(Styles.Colors.backgroundMain))
            }
            .navigationBarTitle("Reports")
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
}

struct PageView: View {
    @Binding var selectedOption: ReportsView.Pages
    let pageWidth = UIScreen.main.bounds.size.width/5
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .new
                }
            }, label: {
                PageViewCell(title: "New", width: pageWidth, page: .new, selectedOption: $selectedOption)
            })
        
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .draft
                }
            }, label: {
                PageViewCell(title: "Draft", width: pageWidth, page: .draft, selectedOption: $selectedOption)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .outbox
                }
            }, label: {
                PageViewCell(title: "Outbox", width: pageWidth, page: .outbox, selectedOption: $selectedOption)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .sent
                }
            }, label: {
                PageViewCell(title: "Sent", width: pageWidth, page: .sent, selectedOption: $selectedOption)
            })
        }
    }
}

struct  PageViewCell: View {
    let title: String
    let width: CGFloat
    let page: ReportsView.Pages
    @Binding var selectedOption: ReportsView.Pages
    
    var body: some View {
        VStack {
            let selected: Bool = page == selectedOption
            Text(title)
                .font(Font.system(size: 15))
                .bold()
                .foregroundColor(selected ? .white : .gray)
                .padding(.bottom, 1)
            Rectangle()
                .fill(selected ?  Color.white : Color.clear)
                .frame(width: width, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ReportsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ReportsView()
    }
}

