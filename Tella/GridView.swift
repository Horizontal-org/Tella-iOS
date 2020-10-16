//
//  GridView.swift
//  A grid that shows content, which can be lazily loaded.
//
//  Created by Thisura Dodangoda on 10/15/20.
//

import SwiftUI
import AVKit
import Foundation

/*
 Module Architecture
 
 GridView: 1 <--layout information-- GridViewModel
 |
  -- GridViewItem: [0..n] <--layout information-- GridViewItemModel
 */


class GridViewModel: ObservableObject{
    
    var gridViewItems: [GridViewItemModel] = []
    var initializedOnce: Bool = false
    
    private var currentProcessingOperation: DispatchWorkItem?
    private var viewRenderingSize: CGSize = .zero
    
    private var initComplete: Bool = false
    private var privKey: SecKey!
    
    private var _previousGalleryWidth: CGFloat = 100.0
    private var _previousSpacing: CGFloat = 100.0
    
    var galleryViewWidth: CGFloat = 100.0{
        didSet{
            if galleryViewWidth != _previousGalleryWidth{
                setNeedsViewUpdate();
            }
            _previousGalleryWidth = galleryViewWidth
        }
    }
    var spacing: CGFloat = 10.0{
        didSet {
            if spacing != _previousSpacing{
                setNeedsViewUpdate();
            }
            _previousSpacing = spacing
        }
    }
    /**
     Width of one item
     */
    var itemViewWidth: CGFloat = 20.0
    /**
     No of columns
     */
    var columns: Int = 3 {
        didSet{
            setNeedsViewUpdate()
        }
    }
    
    @Published var vStacksCount: Int = 0
    @Published var vStackIndexHalfFilled: Int = 0
    @Published var vStackHalfFilledItemCount: Int = 0
    @Published var isProcessing: Bool = false
    @Published var noItemsToShow: Bool = false
    
    init(_ galleryViewWidth: CGFloat, spacing: CGFloat){
        self.galleryViewWidth = galleryViewWidth
        self.spacing = spacing
        
        initComplete = true
        setNeedsViewUpdate()
    }
    
    private func processItems(){
        isProcessing = true
        noItemsToShow = false
         
        if let currentOperation = currentProcessingOperation{
            currentOperation.cancel()
            dispatchWorkItemCleanup()
        }
        
        currentProcessingOperation = DispatchWorkItem(qos: .background, flags: [], block: { [weak self] in
            print("GridView started processing items")
            
            guard let s = self else { return }
            guard s.gridViewItems.count > 0 else {
                DispatchQueue.main.async{
                    s.isProcessing = false
                    s.noItemsToShow = true
                }
                return
            }
            
            let spacingWidth = (CGFloat(s.columns - 1) * s.spacing)
            s.itemViewWidth = (s.galleryViewWidth - (spacingWidth)) / CGFloat(s.columns)
            
            let divResult = s.gridViewItems.count.quotientAndRemainder(dividingBy: s.columns)
            let vStacksCount = divResult.quotient + (divResult.remainder > 0 ? 1 : 0)
            var vStackIndexHalfFilled = -1
            var vStackHalfFilledItemCount = 0
            
            if divResult.remainder > 0{
                vStackIndexHalfFilled = divResult.quotient
                vStackHalfFilledItemCount = divResult.remainder
            }
            
            DispatchQueue.main.async{ [weak self] in
                self?.isProcessing = false
                self?.vStackIndexHalfFilled = vStackIndexHalfFilled
                self?.vStacksCount = vStacksCount
                self?.vStackHalfFilledItemCount = vStackHalfFilledItemCount
                self?.dispatchWorkItemCleanup()
            }
            
            // Process data items
            for item in s.gridViewItems{
                item.processData(privKey: s.privKey)
            }
        })
        
        DispatchQueue.global().async(execute: currentProcessingOperation!)
    }
    
    private func dispatchWorkItemCleanup(){
        currentProcessingOperation = nil
    }
    
    func setNeedsViewUpdate(){
        guard initComplete else { return }
        processItems()
    }
    
    fileprivate func getItem(atRow: Int, column: Int) -> GridViewItemModel?{
        var index = max(0, atRow * columns)
        index += column
        if index < gridViewItems.count{
            return gridViewItems[index]
        }
        else{
            return nil
        }
    }
    
    func addItem(_ item: GridViewItemModel, at: Int){
        if at < gridViewItems.count{
            gridViewItems.insert(item, at: at)
        }
        else{
            gridViewItems.append(item)
        }
        setNeedsViewUpdate()
    }
    
    @discardableResult
    func removeItem(_ at: Int) -> GridViewItemModel?{
        var result: GridViewItemModel?
        if at < gridViewItems.count{
            result = gridViewItems.remove(at: at)
        }
        else{
            result = gridViewItems.popLast()
        }
        
        if result != nil{
            setNeedsViewUpdate()
        }
        
        return result
    }
    
    @discardableResult
    func adjustWidth(_ to: CGFloat) -> GridViewModel{
        self.galleryViewWidth = to
        return self
    }
    
    func setPrivKey(_ privKey: SecKey){
        self.privKey = privKey
    }
}

class GridViewItemModel: ObservableObject{
    enum ViewState{
        case loading, noContent, contentShowing
    }
    
    @Published var viewState: ViewState = .loading
    @Published var idName: String = "unk"
    @Published var type: FileTypeEnum = .IMAGE
    @Published var fileName: String = ""
    
    private var data: Data? = nil
    
    init(){
        
    }
    
    fileprivate func setSelfStateInMain(_ newState: ViewState){
        DispatchQueue.main.async { [weak self] in
            self?.viewState = newState
        }
    }
    
    fileprivate func processData(privKey: SecKey){
        assert(!Thread.isMainThread, "\(#function) Must be run from a Background Thread")
        
        setSelfStateInMain(.loading)
        
        let filePath = TellaFileManager.fileNameToPath(name: fileName)
        data = TellaFileManager.recoverAndDecrypt(filePath, privKey)
        
        // Further processing
        if type == .IMAGE{
            data = getPreviewImage(data)
        }
        
        if data == nil{
            setSelfStateInMain(.noContent)
        }
        else{
            setSelfStateInMain(.contentShowing)
        }
    }
    
    private func getPreviewImage(_ imageData: Data?) -> Data? {
        guard let imageData = imageData else { return nil }
        guard let image = TellaFileManager.recoverImage(imageData) else { return nil }
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        let fixedScaleFactor: CGFloat = 0.05
        let scaleFactor = fixedScaleFactor
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage?.jpegData(compressionQuality: 0.0)
    }
    
    fileprivate func getData() -> Data?{
        return data
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @State var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct GridView: View{
    @ObservedObject var model: GridViewModel
    var onClickAction: ((_ model: GridViewItemModel) -> ())?
    var onDeleteAction: ((_ model: GridViewItemModel) -> ())?
    
    var body: some View {
        ScrollView {
            VStack {
                if model.isProcessing {
                    HStack {
                        ActivityIndicator(isAnimating: true, style: .medium)
                        Text("Loading...").font(.system(size: 8.0))
                    }
                }
                else if model.noItemsToShow{
                    Text("No items to preview").font(.system(size: 8.0))
                }
                else{
                    ForEach(0..<model.vStacksCount, id: \.self){ (i: Int) in
                        HStack(spacing: model.spacing / 2.0) {
                            if (model.vStackIndexHalfFilled == i){
                                // Last row with half filled items
                                ForEach(0..<model.vStackHalfFilledItemCount, id: \.self){ (j: Int) in
                                    if let item = model.getItem(atRow: i, column: j){
                                        GridViewItem(
                                            model: item,
                                            size: model.itemViewWidth) { (onClickModel) in
                                            self.onClickAction?(onClickModel)
                                        } onDelete: { (onDeleteModel) in
                                            self.onDeleteAction?(onDeleteModel)
                                        }.frame(width: model.itemViewWidth, height: model.itemViewWidth)
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }
                            else{
                                // All other rows
                                ForEach(0..<model.columns, id: \.self){ (j: Int) in
                                    if let item = model.getItem(atRow: i, column: j){
                                        GridViewItem(
                                            model: item,
                                            size: model.itemViewWidth) { (onClickModel) in
                                            self.onClickAction?(onClickModel)
                                        } onDelete: { (onDeleteModel) in
                                            self.onDeleteAction?(onDeleteModel)
                                        }.frame(width: model.itemViewWidth, height: model.itemViewWidth)
                                    }
                                    else{
                                        EmptyView()
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }
            }.frame(maxWidth: .infinity)
        }
    }
}

struct GridViewItem: View{
    
    @ObservedObject var model: GridViewItemModel
    var size: CGFloat = 10.0
    fileprivate var onClick: ((_ model: GridViewItemModel) -> ())? = nil
    fileprivate var onDelete: ((_ model: GridViewItemModel) -> ())? = nil
    
    var body: some View {
        ZStack{
            Button {
                onClick?(model)
            } label: {
                VStack {
                    switch(model.viewState){
                    case .loading:
                        ActivityIndicator(isAnimating: model.viewState == .loading, style: .medium)
                    case .noContent:
                        Text("No Contnet")
                    case .contentShowing:
                         
                        switch(model.type){
                        case .IMAGE:
                            GridViewImage(data: model.getData())
                        default:
                            Text("Unsuppported File Type").font(Font.system(size: 8.0))
                        }
                    }
                }
            }
            Button {
                onDelete?(model)
            } label: {
                Text("x")
                    .foregroundColor(Color.white)
                    .frame(width: 40.0, height: 40.0, alignment: .center)
                    .font(.system(size: 12.0))
            }
            .background(Color.black.opacity(0.4))
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(20.0)
            .offset(x: size / 2.0 - 20.0, y: size / 2.0 - 20.0)
        }
    }
}

struct GridViewImage: View{
    var data: Data?
    var body: some View {
        if let data = data, let img = UIImage(data: data) {
            Image(uiImage: img).resizable().scaledToFit()
        }
        else{
            smallText("Image could not be recovered")
        }
    }
}
