//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct BackgroundActivitiesView: View {
    
    @StateObject var viewModel: BackgroundActivitiesViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    
    init(mainAppModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: BackgroundActivitiesViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        
            contentView
                .padding(EdgeInsets(top: 28 , leading: 16, bottom: 0, trailing: 16))
                .frame(alignment: .topLeading)
                .clipped()
    }
    
    private var contentView : some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            Spacer().frame(height: 24)
            activitiesItemView
        }
    }
    
    private var headerView: some View {
        Group {
            
            Text(LocalizableBackgroundActivities.sheetTitle.localized)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .foregroundColor(.white)
            
            Text(viewModel.items.count > 0 ? LocalizableBackgroundActivities.sheetExpl.localized : "There are currently no ongoing activities in the background.")
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
        }
    }
    @ViewBuilder
    private var activitiesItemView : some View {
        if viewModel.items.count > 0 {
             
    
        ScrollView() {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach($viewModel.items, id: \.id) { item in
                    BackgroundActivitiesItemView(item: item)
                }
            }
        }
        }
    }
}

#Preview {
    BackgroundActivitiesView(mainAppModel: MainAppModel.stub())
        .background(Styles.Colors.backgroundTab)
}
