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
    @EnvironmentObject var mainAppModel: MainAppModel

    let diContainer : DIContainer
    
    init(reportMainViewModel: ReportsMainViewModel, diContainer : DIContainer) {
        self.reportsMainViewModel = reportMainViewModel
        self.diContainer = diContainer
    }
    
    var body: some View {
        contentView
            .navigationBarTitle(self.reportsMainViewModel.title, displayMode: .large)
            .environmentObject(reportsMainViewModel)
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
                    showDraftView()
                } .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
                
            }.background(Styles.Colors.backgroundMain)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 16, trailing: 20))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onReceive(reportsMainViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: reportsMainViewModel.toastMessage)
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
                    showDraftView(id: id)
                    
                case .editOutbox:
                    showOutboxView(id: id)
                    
                case .viewSubmitted:
                    showSubmittedView(id: id)
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
        case .finalized,
              .submissionError,
              .submissionPending,
              .submissionPaused,
              .submissionInProgress,
              .submissionAutoPaused,
              .submissionScheduled:
            showOutboxView(id: cardViewModel.id)
            sheetManager.hide()
        case .submitted:
            showSubmittedView(id: cardViewModel.id)
            sheetManager.hide()
        default:
            sheetManager.hide()
        }
    }
    
    private func showDraftView(id:Int? = nil) {
        
        switch reportsMainViewModel.connectionType {
        case .tella:
            var destination: any View
            destination = DraftReportView(mainAppModel: reportsMainViewModel.mainAppModel, reportId: id).environmentObject(reportsMainViewModel)
            self.navigateTo(destination: destination)
            
        case .gDrive:
            var destination : any View
            destination = GDriveDraftView(mainAppModel: reportsMainViewModel.mainAppModel,
                                          gDriveDIContainer: (diContainer as! GDriveDIContainer),
                                          reportId: id).environmentObject(reportsMainViewModel)
            self.navigateTo(destination: destination)
        case .nextcloud:
            var destination : any View
            destination = NextcloudDraftView(mainAppModel: mainAppModel,
                                             nextcloudDIContainer: (diContainer as! NextcloudDIContainer),
                                             reportsViewModel: reportsMainViewModel,
                                             reportId: id)
            self.navigateTo(destination: destination)
        default:
            break
        }
        sheetManager.hide()
    }
    
    private func showOutboxView(id: Int? = nil) {
        switch reportsMainViewModel.connectionType {
        case .tella:
            let outboxViewModel = OutboxReportVM(mainAppModel: mainAppModel,
                                                 reportsViewModel: reportsMainViewModel,
                                                 reportId: id)
            let destination = OutboxDetailsView(outboxReportVM: outboxViewModel,
                                                reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
            break
        case .gDrive:
            let outboxViewModel = GDriveOutboxViewModel(mainAppModel: mainAppModel, 
                                                        reportsViewModel: reportsMainViewModel,
                                                        reportId: id,
                                                        repository: GDriveRepository())
            let destination = OutboxDetailsView(outboxReportVM: outboxViewModel,
                                                reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
       
        case .nextcloud:
            let outboxViewModel = NextcloudOutboxViewModel(mainAppModel: mainAppModel,
                                                           reportsViewModel: reportsMainViewModel,
                                                           reportId: id,
                                                           repository:(diContainer as! NextcloudDIContainer).nextcloudRepository)
            let destination = OutboxDetailsView(outboxReportVM: outboxViewModel, 
                                                reportsViewModel: reportsMainViewModel)
            
            self.navigateTo(destination: destination)
            
        default:
            break
        }
        sheetManager.hide()
    }
    
    private func showSubmittedView(id: Int? = nil) {
        switch reportsMainViewModel.connectionType {
        case .tella:
            let vm = SubmittedReportVM(mainAppModel: mainAppModel, reportId: id)
            let destination = SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        case .gDrive:
            let vm = GDriveSubmittedViewModel(mainAppModel: mainAppModel, reportId: id)
            let destination = SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        case .nextcloud:
            let vm = NextcloudSubmittedViewModel(mainAppModel: mainAppModel, reportId: id)
            let destination = SubmittedDetailsView(submittedReportVM: vm, reportsViewModel: reportsMainViewModel)
            self.navigateTo(destination: destination)
        default:
            break
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
                reportsMainViewModel.deleteSubmittedReport()
            })
        }
    }
}

struct ReportMainView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziView()
    }
}
