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
                .sheet(isPresented: $showingSheet) {
                    AddFileMenuView()
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }
}

struct AddFileMenuView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            Button("Press to dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.title)
            .padding()
            .background(Color.black)
            .frame(height: 200)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    
    static var previews: some View {
        HomeView(viewModel: SettingsModel(), hideAll: HomeView_Previews.$hideAll)
    }
}
