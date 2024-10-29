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
    
    @ObservedObject var reportsMainViewModel: ReportsMainViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var showDraftViewAction: ((Int?) -> Void)?
    var showSubmittedViewAction: ((Int?) -> Void)?
    var showOutboxViewAction: ((Int?) -> Void)?
        
    var body: some View {
        contentView
            .navigationBarTitle(self.reportsMainViewModel.title, displayMode: .large)
            .onAppear(perform: {
                reportsMainViewModel.getReports()
            })
    }
    
    private var contentView :some View {
        
        ContainerView {
            VStack(alignment: .center) {
                
                PageView(selectedOption: self.$reportsMainViewModel.selectedPage, pageViewItems: reportsMainViewModel.pageViewItems)
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    switch self.reportsMainViewModel.selectedPage {
                        
                    case .draft:
                        CommonReportListView(message: LocalizableReport.draftListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsDraftEmpty.localized,
                                             emptyIcon: reportsMainViewModel.connectionType.emptyIcon,
                                             cardsViewModel: $reportsMainViewModel.draftReportsViewModel,
                                             showDetails: showDetailsView(cardViewModel: ),
                                             showBottomSheet: showBottomSheet(cardViewModel:))
                        
                    case .outbox:
                        CommonReportListView(message: LocalizableReport.outboxListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsOutboxEmpty.localized,
                                             emptyIcon: reportsMainViewModel.connectionType.emptyIcon,
                                             cardsViewModel: $reportsMainViewModel.outboxedReportsViewModel,
                                             showDetails: showDetailsView(cardViewModel: ),
                                             showBottomSheet: showBottomSheet(cardViewModel:))
                        
                    case .submitted:
                        CommonReportListView(message: LocalizableReport.submittedListExpl.localized,
                                             emptyMessage: LocalizableReport.reportsSubmitedEmpty.localized,
                                             emptyIcon: reportsMainViewModel.connectionType.emptyIcon,
                                             cardsViewModel: $reportsMainViewModel.submittedReportsViewModel,
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
                    showDraftViewAction?(nil)
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onReceive(reportsMainViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: reportsMainViewModel.toastMessage)
                reportsMainViewModel.shouldShowToast = false
            }
        }
        .if(self.reportsMainViewModel.selectedPage == .submitted && self.reportsMainViewModel.submittedReportsViewModel.count > 0, transform: { view in
            view.toolbar {
                TrailingButtonToolbar(title: LocalizableReport.clearAppBar.localized) {
                    showDeleteAllSubmittedReportConfirmationView()
                }
            }
        })
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
                guard let type = item.type as? ConnectionActionType else {return}
                let id = cardViewModel.id
                
                switch type {
                case .editDraft:
                    showDraftViewAction?(id)
                    sheetManager.hide()
                case .editOutbox:
                    showOutboxViewAction?(id)
                    sheetManager.hide()
                case .viewSubmitted:
                    showSubmittedViewAction?(id)
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
        case .draft:
            showDraftViewAction?(cardViewModel.id)
        case .submitted:
            showSubmittedViewAction?(cardViewModel.id)
        default:
            showOutboxViewAction?(cardViewModel.id)
        }
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
    
    private func showDeleteAllSubmittedReportConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: LocalizableReport.clearSheetTitle.localized,
                               msgText: LocalizableReport.clearSheetExpl.localized,
                               cancelText: LocalizableReport.clearCancel.localized,
                               actionText: LocalizableReport.clearSubmitted.localized, didConfirmAction: {
                sheetManager.hide()
                reportsMainViewModel.deleteSubmittedReports()
            })
        }
    }
}

struct ReportMainView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView()
    }
}
