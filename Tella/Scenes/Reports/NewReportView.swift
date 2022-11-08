//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI

struct NewReportView: View {
    
    @State var title: String = ""
    @State var description: String = ""
    @State var filepath: String = ""
    @State var isShowModel: Bool = false
    @ObservedObject var reportModel = ReportsViewModel()

    @Binding var isPresented : Bool
    
    let screenSize = UIScreen.main.bounds.size

    func sendReport(draft: Bool) {
        guard !self.title.isEmpty,
              !self.description.isEmpty,
              !self.filepath.isEmpty else {
            return
        }
        reportModel.reports.reports.append(ReportDetailsModel.init(title: self.title, description: self.description, filePath: self.filepath, isDraft: draft))
    }

    var body: some View {
        ContainerView {
            
            
                 VStack(alignment:.leading, spacing: 40) {
                     
                     NewReportHeaderView(isPresented: $isPresented)
                     
                    VStack(alignment:.leading){
                        
                        if !title.isEmpty {
                            Text("Title")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        ZStack(alignment: .leading) {
                            if title.isEmpty { Text("Title")
                                    .font(.title)
                                .foregroundColor(.gray) }
                            TextField("Title", text: self.$title)
                                .foregroundColor(.white)
                        }
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: screenSize.width - 40, height: 1, alignment: .center)
                    }
                    .padding(.top, 30)
                    .padding([.leading, .trailing], 20)
                    
                    VStack(alignment:.leading){
                        if !description.isEmpty {
                            Text("Description")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        ZStack(alignment: .leading) {
                            if description.isEmpty {
                                Text("Description")
                                    .font(.title)
                                .foregroundColor(.gray) }
                            Text(self.description)
                                .padding([.leading, .trailing], 5)
                                .padding([.top, .bottom], 8)
                                .foregroundColor(Color.clear)
                            //                        TextEditor(text: self.$description)
                            //                            .foregroundColor(Color.white)
                        }
                        .padding(.trailing, 20)
                        Rectangle()
                            .fill(Color.white)
                            .padding(.trailing, 20)
                            .frame(height: 1)
                    }
                    .padding()
                    
                    VStack(alignment:.leading){
                        Text("Attach files here")
                            .font(Font.system(size: 14))
                            .foregroundColor(.white)
                        Button {
                            self.isShowModel.toggle()
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Styles.Colors.yellow, style: Styles.Stroke.buttonAdd)
                                    .frame(width: 100, height: 100, alignment: .center)
                                Image("report_add")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .leading)
                            }
                        }
                        .sheet(isPresented: self.$isShowModel) {
                            DocumentPicker(fileContent: self.$filepath, showModel: self.$isShowModel)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 15){
                        HStack(spacing: 20) {
                            Spacer()
                            Button(action: {
                                
                            }, label: {
                                VStack {
                                    Text("DISCARD".uppercased())
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(width:(screenSize.width / 2) - 30 , height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .background(Styles.Colors.backgroundTab)
                                .cornerRadius(25)
                            })
                            Button(action: {
                                self.sendReport(draft: true)
                            }, label: {
                                VStack {
                                    Text("Save Draft".uppercased())
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(width: (screenSize.width / 2) - 30, height: 50, alignment: .center)
                                .background(Styles.Colors.backgroundTab)
                                .cornerRadius(25)
                            })
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        
                        Button(action: {
                            self.sendReport(draft: false)
                        }, label: {
                            VStack {
                                Text("Send".uppercased())
                                    .font(.callout)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(width: screenSize.width  - 40, height: 60, alignment: .center)
                            .background(Styles.Colors.backgroundTab)
                            .cornerRadius(25)
                            
                        })
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 20)
                        Spacer()
                    }
                }
                .background(Styles.Colors.backgroundMain)
            }
            .background(Styles.Colors.backgroundMain)
            
     }
    
}

struct NewReportHeaderView : View {
    
    @Binding var isPresented : Bool
    
    var body: some View {
        
        HStack {
            Button {
                isPresented = false
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
            
            Text("Report")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            Spacer()
        }.padding(.top, 15)
        
    }
}



//struct NewMailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewReportView(title: .constant("New Report"), description: .constant("Report Description"))
//    }
//}

