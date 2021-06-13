//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI


struct HomeView: View {

    @Binding var hideAll: Bool
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddFileSheet = false
    @State private var showingAddFileSheet1 = false

    init(viewModel: HomeViewModel, hideAll: Binding<Bool>) {
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
                        RecentFilesListView(viewModel: viewModel)
                        FileGroupsView(viewModel: viewModel)
                    }
                }
                AddFileButtonView(action: {
                    showingAddFileSheet.toggle()
                })
                .actionSheet(isPresented: $showingAddFileSheet1) {
                    addFileActionSheet()
                }
                //TODO: replace with AddFileBottomSheetFileActions
                //AddFileBottomSheetFileActions(isPresented: $showingAddFileSheet)
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
                NavigationLink(destination: SettingsView(viewModel: viewModel.settings)) {
                            Image("home.settings")
                                .imageScale(.large)
                            }
                    }.background(Color(Styles.Colors.backgroundMain))
                )
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
    
    func addFileActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Change background"),  buttons: [
            .default(Text("Take Photos/Videos")) {
            },
            .default(Text("Record Audio")) { },
            .default(Text("Import From Device")) { },
            .default(Text("Import and delete original")) { },
            .cancel()
        ])
    }
    
}



struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(), hideAll: HomeView_Previews.$hideAll)
    }
}

