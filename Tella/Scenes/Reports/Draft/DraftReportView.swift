//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DraftReportView: View {
    
//    var isPresented : Binding<Bool>
    @StateObject var reportViewModel : DraftReportVM
    
    @State private var menuFrame : CGRect = CGRectZero
    @State private var shouldShowMenu : Bool = false
    @State private var shouldShowSelectFiles : Bool = false
    @State private var shouldShowNavBar : Bool = false

    @EnvironmentObject var mainAppModel : MainAppModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(mainAppModel: MainAppModel, isPresented : Binding<Bool>, report:Report? = nil) {
//        self.isPresented = isPresented
        _reportViewModel = StateObject(wrappedValue: DraftReportVM(mainAppModel: mainAppModel,report:report))
    }
    
    var body: some View {
        
        ContainerView {
            
            ZStack {
                VStack(alignment: .leading) {
                    
                    draftReportHeaderView
                    
                    draftContentView
                    
                    bottomDraftView
                }
                
                serverListMenuView
                
//                AddFilesToDraftView(shouldShowSelectFiles: $shouldShowSelectFiles)

            }
        }
        .onAppear(perform: {
            shouldShowNavBar = true
        })
        .onTapGesture {
            shouldShowMenu = false
        }
        .navigationBarHidden(true)

    }
    
    var draftReportHeaderView: some View {
        
        HStack(spacing: 0) {
            Button {
//                self.isPresented.wrappedValue = false
                self.presentationMode.wrappedValue.dismiss()
                shouldShowNavBar = false

            } label: {
                Image("close")
                    .padding(EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 16))
            }
            
            Text("Report")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button {
                reportViewModel.status = .draft
                reportViewModel.saveReport()
//                self.isPresented.wrappedValue = false
                
            } label: {
                Image("reports.save")
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .opacity(reportViewModel.reportIsDraft ? 1 : 0.4)
            }.disabled(!reportViewModel.reportIsDraft)
            
            
        }.frame(height: 56)
    }
    
//    var attachedFile : some View {
//        
//        VStack {
//            Text("Attach files here")
//                .font(.custom(Styles.Fonts.regularFontName, size: 14))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.leading)
//            
//            Button {
//                shouldShowSelectFiles = true
//            } label: {
//                Image("reports.add")
//            }
//        }
//    }
    
    var draftContentView: some View {
        
        GeometryReader { geometry in
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    if reportViewModel.hasMoreServer  {
                        
                        Text("Send report to:")
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .foregroundColor(Color.white)
                        
                        Button {
                            self.menuFrame = geometry.frame(in: CoordinateSpace.global)
                            shouldShowMenu = true
                            
                        } label: {
                            HStack {
                                Text(reportViewModel.serverName)
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
                            .frame(height: 55)
                        
                    } else {
                        Spacer()
                            .frame(height: 10)
                        
                    }
                    
                    TextfieldView(fieldContent: $reportViewModel.title,
                                  isValid: $reportViewModel.isValidTitle,
                                  shouldShowError: $reportViewModel.shouldShowError,
                                  fieldType: .text,
                                  placeholder : "Title",
                                  shouldShowTitle: reportViewModel.hasMoreServer)
                    .frame(height: 30)
                    
                    Spacer()
                        .frame(height: 34)
                    
                    TextEditorView(placeholder: "Description",
                                   fieldContent: $reportViewModel.description,
                                   isValid: $reportViewModel.isValidDescription,
                                   shouldShowError: $reportViewModel.shouldShowError,
                                   shouldShowTitle: reportViewModel.hasMoreServer)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    AddFilesToDraftView(appModel: MainAppModel(),
                                        rootFile: mainAppModel.vaultManager.root,
                                        fileType: nil)
                    
                    Spacer()
                    
                }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
    
    @ViewBuilder
    var serverListMenuView: some View {
        
        if shouldShowMenu {
            VStack {
                Spacer()
                    .frame(height: menuFrame.origin.y +  10)
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(reportViewModel.serverArray, id: \.self) { server in
                            
                            Button {
                                shouldShowMenu = false
                                reportViewModel.server = server
                                
                            } label: {
                                Text(server.name ?? "")
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.all, 14)
                            }.background(server.id == reportViewModel.server?.id ? Color.white.opacity(0.16) : Color.white.opacity(0.08))
                        }
                    }.frame(minHeight: 40, maxHeight: 250)
                        .background(Styles.Colors.backgroundMain)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
            
            .background(Color.clear)
        }
    }
    
    var bottomDraftView: some View {
        
        HStack {
            
            Button {
                reportViewModel.status = .outbox
                reportViewModel.saveReport()
//                self.isPresented.wrappedValue = false
            } label: {
                Image("reports.submit-later")
                    .opacity(reportViewModel.reportIsDraft ? 1 : 0.4)
            }.disabled(!reportViewModel.reportIsDraft)
            
            
            TellaButtonView<AnyView> (title: "SUBMIT",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: $reportViewModel.reportIsValid) {
                
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
    }
}

struct DraftReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        DraftReportView(mainAppModel: MainAppModel(), isPresented: .constant(true))
            .environmentObject(ReportsViewModel(mainAppModel: MainAppModel()))
    }
}
