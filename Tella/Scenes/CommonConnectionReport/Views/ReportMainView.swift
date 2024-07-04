//
//  ReportMainView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct ReportMainView: View {
    
    @State var reportMainViewModel: ReportMainViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel: MainAppModel
    
    
    let diContainer : DIContainer
    
    init(reportMainViewModel: ReportMainViewModel, diContainer : DIContainer) {
        self.reportMainViewModel = reportMainViewModel
        self.diContainer = diContainer
    }
    
    var body: some View {
        contentView
            .navigationBarTitle(self.reportMainViewModel.title, displayMode: .large)
            .environmentObject(reportMainViewModel)
    }
    
    private var contentView :some View {
        
        ContainerView {
            VStack(alignment: .center) {
                
                PageView(selectedOption: $reportMainViewModel.selectedCell, pageViewItems: reportMainViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    switch self.reportMainViewModel.selectedCell {
                        
                    case .draft:
                        CommonReportListView(message: LocalizableReport.draftListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsDraftEmpty.localized,
                                             cardsViewModel: $reportMainViewModel.draftReportsViewModel,
                                             showDetails: showDetailsView(cardViewModel: ),
                                             showBottomSheet: showBottomSheet(cardViewModel:))
                        
                    case .outbox:
                        CommonReportListView(message: LocalizableReport.outboxListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsOutboxEmpty.localized,
                                             cardsViewModel: $reportMainViewModel.outboxedReportsViewModel,
                                             showDetails: showDetailsView(cardViewModel: ),
                                             showBottomSheet: showBottomSheet(cardViewModel:))
                        
                    case .submitted:
                        CommonReportListView(message: LocalizableReport.submittedListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsSubmitedEmpty.localized,
                                             cardsViewModel: $reportMainViewModel.submittedReportsViewModel,
                                             showDetails: showDetailsView(cardViewModel: ),
                                             showBottomSheet: showBottomSheet(cardViewModel:))
                    default:
                        EmptyView()
                    }
                    
                    Spacer()
                }
                
                TellaButtonView<AnyView> (title: LocalizableReport.reportsCreateNew.localized,
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    showDraftView()
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onReceive(reportMainViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: reportMainViewModel.toastMessage)
            }
        }
        
    }
    
    var backButton : some View {
        Button {
            self.popToRoot()
        } label: {
            Image("back")
                .flipsForRightToLeftLayoutDirection(true)
                .padding(EdgeInsets(top: -3, leading: -8, bottom: 0, trailing: 12))
        }
    }
    
    
    private func showBottomSheet(cardViewModel:CommonCardViewModel) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            
            ActionListBottomSheet(items: cardViewModel.listActionSheetItem,
                                  headerTitle: cardViewModel.title,
                                  action:  {item in
                guard let type = item.type as? ReportActionType else {return}
                let id = cardViewModel.id

                switch type {
                case .editDraft:
                    showDraftView(id: id)
                    
                case .editOutbox:
                    showOutboxView()
                    
                case .viewSubmitted:
                    showSubmittedEntityView()
                    sheetManager.hide()
                    
                case .delete:
                    showDeleteReportConfirmationView(cardViewModel: cardViewModel)
                    
                }
            })
        }
    }
    
    private func showDetailsView(cardViewModel:CommonCardViewModel) {
        
        guard let cardViewModel = cardViewModel as? ReportCardViewModel else { return }
        switch cardViewModel.status {
        case .unknown, .draft:
            showDraftView(id: cardViewModel.id)
            sheetManager.hide()
        case .submitted:
            sheetManager.hide()
        default:
            sheetManager.hide()
        }
    }
    
    private func showDraftView(id:Int? = nil) {

        switch reportMainViewModel.connectionType {
        case .tella:
            break
        case .gDrive:
            var destination : any View
            let draftViewModel = GDriveDraftViewModel(mainAppModel: mainAppModel,
                                                      repository: (diContainer as! GDriveDIContainer).gDriveRepository,
                                                      reportID: id)
            destination = DraftView(viewModel:draftViewModel, reportsViewModel: reportMainViewModel)
            self.navigateTo(destination: destination)

        case .nextcloud:
            var destination : any View
            let draftViewModel = GDriveDraftViewModel(mainAppModel: mainAppModel,
                                                      repository: (diContainer as! GDriveDIContainer).gDriveRepository,
                                                      reportID: id)
            destination = DraftView(viewModel:draftViewModel, reportsViewModel: reportMainViewModel)
            self.navigateTo(destination: destination)
            
        default:
            break
        }
        sheetManager.hide()
    }
    
    private func showOutboxView() {
        sheetManager.hide()
    }
    
    private func showSubmittedEntityView() {
        sheetManager.hide()
    }
    
    private func showDeleteReportConfirmationView(cardViewModel:CommonCardViewModel) {
        
        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: cardViewModel.deleteReportStrings.deleteTitle,
                                      msgText: cardViewModel.deleteReportStrings.deleteMessage,
                                      cancelText: LocalizableReport.deleteCancel.localized,
                                      actionText: LocalizableReport.deleteConfirm.localized) {
                cardViewModel.deleteAction()
            }
        }
    }
}

struct ReportMainView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView()
    }
}
