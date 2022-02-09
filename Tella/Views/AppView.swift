//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

class DragViewData  {

   var modalHeight : CGFloat = 0.0
     var isPresented :  Binding<Bool> = .constant(false)
     var content : AnyView? = nil
    init() {
        
    }
    init(modalHeight : CGFloat = 0.0,
         isPresented :  Binding<Bool>  = .constant(false) ,
           content : AnyView? = nil) {
        
        self.modalHeight =  modalHeight
        self.isPresented  =  isPresented
        self.content  =  content
    }
}

struct AppView: View  {
    
    @State private var hideAll = false
    @State private var hideTabBar = false
    @EnvironmentObject private var appModel: MainAppModel
    
    @State private var inputImage: UIImage?
    
    @State private var showingRecoredrView : Bool = false

    init() {
        setDebugLevel(level: .debug, for: .app)
        setDebugLevel(level: .debug, for: .crypto)
        setupApperance()
        
        
    }
    
    var body: some View {
        if hideAll {
            emptyView
        } else {
            ZStack {
                tabbar
                
                DragView(modalHeight: self.appModel.content.modalHeight,
                         color: Styles.Colors.backgroundTab,
                         isShown: self.appModel.content.isPresented) {
                    self.appModel.content.content
                }
            }

        }
    }
    
    private var emptyView: some View{
        VStack{
        }.background(Styles.Colors.backgroundMain)
    }
    
    private var tabbar: some View{
        NavigationView {
            ZStack {
            
            TabView(selection: $appModel.selectedTab) {
                HomeView(appModel: appModel, hideAll: $hideAll)
                    .tabItem {
                        Image("tab.home")
                        Text("Home")
                    }.tag(MainAppModel.Tabs.home)
#if DEBUG
                ReportsView()
                    .tabItem {
                        Image("tab.reports")
                        Text("Reports")
                    }.tag(MainAppModel.Tabs.reports)
                FormsView()
                    .tabItem {
                        Image("tab.forms")
                        Text("Forms")
                    }.tag(MainAppModel.Tabs.forms)
#endif
                CustomCameraView(completion: { image in
                    if let image = image {
                        self.appModel.add(image: image, to: appModel.vaultManager.root, type: .image, pathExtension: "png")
                    }
                })
                    .tabItem {
                        Image("tab.camera")
                        Text("Camera")
                    }.tag(MainAppModel.Tabs.camera)

                ContainerView{}
                    .tabItem {
                        Image("tab.mic")
                        Text("Mic")
                    }.tag(MainAppModel.Tabs.mic)
            }
              
                if appModel.selectedTab == .mic   {
                    RecordView( showingRecoredrView: $showingRecoredrView)
                 }
                
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingView
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingView
                }
            }
            
        }
        .navigationViewStyle(.stack)
        
          
        .accentColor(.white)

        
            .navigationBarTitle("Tella", displayMode: .inline)
            .navigationBarHidden(appModel.selectedTab == .home ? false : true)
            
     }
    

    private func setupApperance() {
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.init(hexValue: 0x918FAC)
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.init(hexValue: 0x3D3771)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white,
                                                          
                                                          NSAttributedString.Key.font: UIFont.init(name: Styles.Fonts.regularFontName, size: 12)!],for: .normal)
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = Styles.uiColor.backgroundMain
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                 .font: UIFont(name: Styles.Fonts.boldFontName, size: 24)!]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                                      .font: UIFont(name: Styles.Fonts.boldFontName, size: 24)!]
        coloredAppearance.setBackIndicatorImage(UIImage(named: "back"), transitionMaskImage: UIImage(named: "back"))
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().backgroundColor = Styles.uiColor.backgroundMain
    }
    
    @ViewBuilder
    private var leadingView : some View {
        
        if appModel.selectedTab == .home {
            Image("home.settings")
                .frame(width: 19, height: 20)
                .aspectRatio(contentMode: .fit)
                .navigateTo(destination: SettingsMainView(appModel: appModel))
        }
    }
    
    @ViewBuilder
    private var trailingView : some View {
        
        if appModel.selectedTab == .home {
            Button {
                hideAll = true
            } label: {
                Image("home.close")
                    .imageScale(.large)
            }
        }
    }
    
}

//struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppView()
//            .preferredColorScheme(.light)
//            .previewLayout(.device)
//            .previewDevice("iPhone Xʀ")
//            .environmentObject(MainAppModel())
//    }
//}
