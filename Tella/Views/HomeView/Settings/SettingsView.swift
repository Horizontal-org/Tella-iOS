//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsView : View {
    
    @ObservedObject var viewModel: SettingsModel
    
    init(viewModel: SettingsModel) {
        self.viewModel = viewModel
        setupView()
    }
    
    private func setupView() {
    }
    
    var body: some View {
        ZStack {
            Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
            Form {
                Section{
                    SettingToggleItem(title: "Offline mode", description: "In offline Mode, all data is save for later submission. Useful to save cellular data or when connectivity is poor. Disable when you're ready to submit forms.", toggle: $viewModel.offLineMode)
                }
                .listRowBackground(Color(Styles.Colors.backgroundTab))
                Section {
                    SettingMenu(viewModel: viewModel)
                }
            }.background(Color(Styles.Colors.backgroundMain))
        }.onAppear() {
            UITableView.appearance().backgroundColor = UIColor.clear
            UITableView.appearance().separatorStyle = .singleLine
            UITableView.appearance().separatorColor = .white
            UISwitch.appearance().onTintColor = .green
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingMenu: View {
    
    @ObservedObject var viewModel: SettingsModel

    var body: some View {
        List{
//            NavigationLink(destination: SettingsAboutHelp()) {
//                SettingItem(name: "General", image: Image(systemName: "gear"))
//            }
            NavigationLink(destination: SettingsSecurity(viewModel: viewModel)) {
                SettingItem(name: "Security", image: Image(systemName: "person.crop.circle.badge.exclam"))
            }
            NavigationLink(destination: SettingsDocumentation()) {
                SettingItem(name: "Documentation", image: Image(systemName: "hand.raised.fill"))
            }
            NavigationLink(destination: SettingsAboutHelp()) {
                SettingItem(name: "About & Help", image: Image(systemName: "key.fill"))
            }
        }
        .listRowBackground(Color(Styles.Colors.backgroundTab))
        .cornerRadius(25)
    }
}

struct SettingItem: View {

    let name: String
    let image: Image
    
    var body: some View {
        HStack{
            image
                .frame(width: 25, height: 25)
                .foregroundColor(Color.white)
            Text(name)
                .font(.callout)
                .foregroundColor(Color.white)
        }
        .frame(height: 56)
        .listRowBackground(Color(Styles.Colors.backgroundTab))
        .cornerRadius(25)
    }
}

struct SettingToggleItem: View {

    let title: String
    let description: String
    @Binding var toggle: Bool
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white).padding(.bottom, -5)
                
                Toggle(description, isOn: $toggle)
                    .foregroundColor(Color.white)
                    .font(Font(UIFont.systemFont(ofSize: 11)))
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
    }
}

struct DemoDesign_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SettingsView(viewModel: SettingsModel())
        }
    }
}
