//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DraftReportView: View {
    
    @Binding var isPresented : Bool
    @EnvironmentObject var reportViewModel : ReportsViewModel
    
    @State var framee : CGRect = CGRectZero
    @State var shouldShowMenu : Bool = false
    
    
    var body: some View {
        
        ContainerView {
            
            ZStack {
                
                VStack(alignment: .leading) {
                    
                    draftReportHeaderView
                    
                    draftContentView
                    
                    bottomDraftView
                }
                
                serverListMenuView
            }
        }
        .onTapGesture {
            shouldShowMenu = false
        }
    }
    
    var draftReportHeaderView: some View {
        
        HStack(spacing: 0) {
            Button {
                isPresented = false
            } label: {
                Image("close")
                    .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 16))
            }
            
            Text("Report")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button {
                
            } label: {
                Image("reports.save")
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .opacity(reportViewModel.currentReportVM.reportIsDraft ? 1 : 0.4)
            }.disabled(!reportViewModel.currentReportVM.reportIsDraft)
            
            
        }.frame(height: 56)
    }
    
    var attachedFile : some View {
        
        VStack {
            Text("Attach files here")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Button {
                
            } label: {
                Image("reports.add")
            }
        }
    }
    
    var draftContentView: some View {
        
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                
                Text("Send report to:")
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white)
                
                Button {
                    self.framee = geometry.frame(in: CoordinateSpace.global)
                    shouldShowMenu = true
                    
                } label: {
                    
                    HStack {
                        
                        Text("Select your project")
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .foregroundColor(Color.white.opacity(0.87))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image("reports.arrow-down")
                            .padding()
                        
                    }
                }.background(Color.white.opacity(0.08))
                    .cornerRadius(12)

                Spacer()
                    .frame(height: 40)

                TextfieldView(fieldContent: $reportViewModel.currentReportVM.title,
                              isValid: $reportViewModel.currentReportVM.isValidTitle,
                              shouldShowError: $reportViewModel.currentReportVM.shouldShowError,
                              errorMessage: nil,
                              fieldType: .text,
                              title : "Title")
                .frame(height: 30)
                
                Spacer()
                    .frame(height: 24)
                
                TextEditorView(placeholder: "Description",
                               fieldContent: $reportViewModel.currentReportVM.description,
                               isValid: $reportViewModel.currentReportVM.isValidDescription, shouldShowError: $reportViewModel.currentReportVM.shouldShowError)
                
                Spacer()
                    .frame(height: 24)
                
                attachedFile
                
                Spacer()
                
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
    
    @ViewBuilder
    var serverListMenuView: some View {
        if shouldShowMenu {
            VStack {
                Spacer()
                    .frame(height: framee.origin.y +  10)
                ScrollView {
                    
                    VStack(spacing: 0) {
                        ForEach(reportViewModel.servers, id: \.self) { server in
                            
                            Button {
                                shouldShowMenu = false
                            } label: {
                                Text(server.name)
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.all, 14)
                            }.background(server.id == 20 ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
                        }
                    }
                }.frame(maxHeight: 250)
                    .background(Styles.Colors.backgroundMain)
                    .cornerRadius(12)
                Spacer()
            }
            .padding()
            
            .background(Color.clear)
        }
    }
    
    var bottomDraftView: some View {
        
        HStack {
            
            Button {
                
            } label: {
                Image("reports.submit-later")
                    .opacity(reportViewModel.currentReportVM.reportIsDraft ? 1 : 0.4)
            }.disabled(!reportViewModel.currentReportVM.reportIsDraft)
            
            
            TellaButtonView<AnyView> (title: "SUBMIT",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: $reportViewModel.currentReportVM.reportIsValid) {
                
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
    }
}

struct DraftReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        DraftReportView(isPresented: .constant(true))
            .environmentObject(ReportsViewModel(mainAppModel: MainAppModel()))
    }
}
