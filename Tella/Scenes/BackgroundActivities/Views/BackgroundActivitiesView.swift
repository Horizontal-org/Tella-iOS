//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct BackgroundActivitiesView: View {
    
    @StateObject var viewModel: BackgroundActivitiesViewModel =  BackgroundActivitiesViewModel()
    
    var body: some View {
        
        GeometryReader { geometry in
            contentView
                .padding(EdgeInsets(top: 28 , leading: 16, bottom: 0, trailing: 16))
                .frame(height: geometry.size.height)
                .frame(alignment: .topLeading)
                .clipped()
        }
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
            HStack(spacing: 14) {
                
                Image("home.progress-circle")
                
                Text(LocalizableBackgroundActivities.sheetTitle.localized)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
            }
            
            Text(LocalizableBackgroundActivities.sheetExpl.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 13))
                .foregroundColor(.white)
        }
    }
    
    private var activitiesItemView : some View {
        ScrollView() {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach($viewModel.items, id: \.id) { item in
                    BackgroundActivitiesItemView(item: item)
                }
            }
        }
    }
}

#Preview {
    BackgroundActivitiesView()
        .background(Styles.Colors.backgroundTab)
}
