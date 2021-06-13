//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct HomeView: View {

    @Binding var hideAll: Bool
    @ObservedObject var viewModel: SettingsModel
    @State private var showingSheet = false
    
    init(viewModel: SettingsModel, hideAll: Binding<Bool>) {
        self.viewModel = viewModel
        self._hideAll = hideAll
        setupView()
    }
    
    private func setupView() {
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(spacing: 0){
                    ScrollView{
                        ReventFilesListView()
                        FileGroupsView()
                    }
                }
                buttonView
                    .actionSheet(isPresented: $showingSheet) {
                        ActionSheet(title: Text("Change background"),  buttons: [
                            .default(Text("Take Photos/Videos")) {
                            },
                            .default(Text("Record Audio")) { },
                            .default(Text("Import From Device")) { },
                            .default(Text("Import and delete original")) { },
                            .cancel()
                        ])
                    }
//                AddFileBottomSheetFileActions(isPresented: $showingSheet)
            }
            .navigationBarTitle("Tella")
            .navigationBarItems(trailing:
                    HStack(spacing: 8) {
                    Button {
                        hideAll = true
                    } label: {
                        Image("home.close")
                            .imageScale(.large)
                        }
                        NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                            Image("home.settings")
                                .imageScale(.large)
                            }
                    }.background(Color(Styles.Colors.backgroundMain))
                )
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
    
    var buttonView: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    //TODO: add new media action
                    showingSheet.toggle()
                }) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 50, height: 50, alignment: .center)
                        .overlay(Image("home.add"))
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }
}

struct AddFileBottomSheetFileActions: View {
    @Binding var isPresented: Bool
    
    let items = [
        ListActionSheetItem(imageName: "upload-icon", content: "Take photo/video", action: {
        }),
        ListActionSheetItem(imageName: "upload-icon", content: "Record audio", action: {}),
        ListActionSheetItem(imageName: "upload-icon", content: "Import from device", action: {}),
        ListActionSheetItem(imageName: "delete-icon", content: "Import and delete original file", action: {})
    ]
    
    var body: some View {
        VStack{
            DragView(modalHeight: CGFloat(items.count * 40 + 100), color: Color(Styles.Colors.backgroundTab), isShown: $isPresented){
                ListActionSheet(items: items, headerTitle: "Add file to ...", isPresented: $isPresented)
            }
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    
    static var previews: some View {
        HomeView(viewModel: SettingsModel(), hideAll: HomeView_Previews.$hideAll)
    }
}
