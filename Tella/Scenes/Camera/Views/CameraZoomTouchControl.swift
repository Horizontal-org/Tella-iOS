//
//  CameraZoomTouchControl.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import UIKit

struct CameraZoomTouchControl: View {
    // MARK: - Public properties
    
    let zoomLevels: [CameraZoomLevel]
    let zoomLenses: [CameraZoomLens]
    let zoomFactor: CGFloat
    let zoomRange: ClosedRange<CGFloat>
    let zoomFrame: CGRect
    let dialFrame: CGRect
    /// Includes the preview and zoom row while leaving the header and capture controls reachable.
    let interactionFrame: CGRect
    @Binding var isExpanded: Bool
    let rotation: CameraControlRotation
    let onZoomChanged: (CGFloat) -> Void
    let onSelectZoomLevel: (CameraZoomLevel) -> Void
    
    // MARK: - Private state
    
    @Environment(\.isEnabled) private var isEnabled
    @GestureState private var isPressingPreset = false
    @GestureState private var isDraggingDial = false
    @GestureState private var isMagnifying = false
    @State private var isAdjustingZoom = false
    @State private var localZoomFactor: CGFloat = 1
    @State private var previousAngle: CGFloat?
    @State private var hasDragged = false
    @State private var pinchStartFactor: CGFloat?
    @State private var zoomFeedback = UISelectionFeedbackGenerator()
    
    // MARK: - Constants
    
    private static let gestureSpace = "CameraZoomTouchControl"
    private static let presetPressDuration = 0.15
    private static let presetPressDistance: CGFloat = 16
    private static let dialIdleDelay: UInt64 = 3_000_000_000
    private static let minimumZoomChange: CGFloat = 0.0001
    private static let dialDragCeilingInset: CGFloat = 20
    
    // MARK: - Derived state
    
    private var scale: CameraZoomScale { CameraZoomScale(range: zoomRange) }
    private var geometry: CameraZoomDialGeometry { CameraZoomDialGeometry(zoomFrame: dialFrame) }
    private var canZoom: Bool { scale.range.upperBound > scale.range.lowerBound }
    private var isInteracting: Bool { isPressingPreset || isDraggingDial || isMagnifying }
    private var displayedZoomFactor: CGFloat {
        scale.clampedFactor(isAdjustingZoom ? localZoomFactor : zoomFactor)
    }
    private var presetFrame: CGRect {
        CGRect(x: zoomFrame.midX - CGFloat(zoomLevels.count) * .mediumIconSize / 2,
               y: zoomFrame.midY - .mediumIconSize / 2,
               width: CGFloat(zoomLevels.count) * .mediumIconSize, height: .mediumIconSize)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .frame(width: interactionFrame.width, height: interactionFrame.height)
                .position(x: interactionFrame.midX, y: interactionFrame.midY)
                .onTapGesture { isExpanded = false }
                .allowsHitTesting(isExpanded || isMagnifying)
            
            presets
                .opacity(isExpanded || !canZoom ? 0 : 1)
                .simultaneousGesture(presetGesture)
                .allowsHitTesting(!isExpanded || isPressingPreset)
                .position(x: zoomFrame.midX, y: zoomFrame.midY)
            
            if isExpanded && canZoom {
                CameraZoomDialView(zoomFactor: displayedZoomFactor,
                                   zoomRange: zoomRange,
                                   zoomLenses: zoomLenses,
                                   zoomFrame: dialFrame,
                                   rotation: rotation)
                .allowsHitTesting(false)
            }
            
            CameraZoomDialShape(zoomFrame: dialFrame)
                .fill(Color.clear)
                .contentShape(CameraZoomDialShape(zoomFrame: dialFrame))
                .gesture(dialDragGesture)
                .allowsHitTesting(isExpanded)
        }
        .coordinateSpace(name: Self.gestureSpace)
        .contentShape(Path(isExpanded || isMagnifying ? interactionFrame : presetFrame))
        .simultaneousGesture(pinchGesture)
        .allowsHitTesting(isEnabled && canZoom)
        .onChange(of: canZoom) { isAvailable in
            if !isAvailable { isExpanded = false }
        }
        .onChange(of: isInteracting) { isActive in
            guard !isActive else { return }
            isAdjustingZoom = false
            previousAngle = nil
            hasDragged = false
            pinchStartFactor = nil
        }
        .task(id: isExpanded && !isInteracting) {
            guard isExpanded, !isInteracting else { return }
            do {
                try await Task.sleep(nanoseconds: Self.dialIdleDelay)
            } catch {
                return
            }
            guard !Task.isCancelled, !isInteracting else { return }
            isExpanded = false
        }
    }
    
    // MARK: - Presets
    
    private var presets: some View {
        let active = CameraZoomLevel.active(for: displayedZoomFactor, in: zoomLevels)
        return HStack(spacing: 0) {
            ForEach(zoomLevels) { level in
                let selected = level == active
                Button {
                    guard !isExpanded else { return }
                    onSelectZoomLevel(level)
                } label: {
                    Text(selected ? CameraZoomLevel(factor: displayedZoomFactor).title + "x" : level.title)
                        .font(Font(TypographyStyle.subheading2Style.font))
                        .foregroundColor(selected ? Styles.Colors.backgroundGrey1 : .white)
                        .rotate(rotation)
                        .frame(width: .smallIconSize, height: .smallIconSize)
                        .background(Capsule().fill(selected ? Styles.Colors.grey1 : Styles.Colors.backgroundGrey2))
                        .frame(width: .mediumIconSize, height: .mediumIconSize)
                        .contentShape(Rectangle())
                }
            }
        }
        .frame(width: presetFrame.width, height: presetFrame.height)
        .contentShape(Rectangle())
    }
    
    // MARK: - Gestures
    
    /// This host stays mounted when the dial appears, preserving the original finger.
    private var presetGesture: some Gesture {
        LongPressGesture(minimumDuration: Self.presetPressDuration,
                         maximumDistance: Self.presetPressDistance)
        .onEnded { recognized in
            guard recognized, !isMagnifying else { return }
            beginAdjustment()
            isExpanded = true
        }
        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.gestureSpace)))
        .updating($isPressingPreset) { _, isActive, _ in isActive = true }
        .onChanged { value in
            guard case .second(true, let drag) = value, !isMagnifying else { return }
            if let drag {
                adjustZoom(with: drag, verticalOffset: dialFrame.midY - zoomFrame.midY)
            }
        }
    }
    
    private var dialDragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.gestureSpace))
            .updating($isDraggingDial) { _, isActive, _ in isActive = true }
            .onChanged { value in
                guard !isMagnifying else { return }
                if !isAdjustingZoom { beginAdjustment() }
                adjustZoom(with: value)
            }
    }
    
    /// Keep the preview's gesture alive until a pinch finishes, even after collapse.
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .updating($isMagnifying) { _, isActive, _ in
                isActive = isExpanded || pinchStartFactor != nil
            }
            .onChanged { magnification in
                guard isExpanded || pinchStartFactor != nil else { return }
                if pinchStartFactor == nil {
                    let initial = displayedZoomFactor
                    beginAdjustment()
                    pinchStartFactor = initial
                    isExpanded = false
                }
                guard let initial = pinchStartFactor else { return }
                updateZoom(scale.clampedFactor(initial * magnification))
            }
    }
    
    // MARK: - Zoom adjustment
    
    private func beginAdjustment() {
        localZoomFactor = displayedZoomFactor
        isAdjustingZoom = true
        previousAngle = nil
        hasDragged = false
        zoomFeedback.prepare()
    }
    
    private func adjustZoom(with value: DragGesture.Value, verticalOffset: CGFloat = 0) {
        guard isExpanded else { return }
        let location = CGPoint(x: value.location.x, y: value.location.y + verticalOffset)
        let startLocation = CGPoint(x: value.startLocation.x, y: value.startLocation.y + verticalOffset)
        guard location.y < geometry.wheelCenter.y - Self.dialDragCeilingInset else {
            previousAngle = nil
            hasDragged = true
            return
        }
        let current = geometry.angle(at: location)
        let previous = previousAngle ?? (hasDragged ? current : geometry.angle(at: startLocation))
        updateZoom(scale.factor(from: displayedZoomFactor, angleDelta: current - previous))
        // Rebase every step so reversing after reaching a limit responds immediately.
        previousAngle = current
        hasDragged = true
    }
    
    private func updateZoom(_ value: CGFloat) {
        guard abs(value - localZoomFactor) > Self.minimumZoomChange else { return }
        // Match feedback to the displayed tenths, rather than every drag update.
        if isExpanded && (value * 10).rounded() != (localZoomFactor * 10).rounded() {
            zoomFeedback.selectionChanged()
            zoomFeedback.prepare()
        }
        localZoomFactor = value
        onZoomChanged(value)
    }
}

// MARK: - Dial background

/// Continues the wheel behind the lower controls without extending its gesture area.
struct CameraZoomDialBackground: View {
    let zoomFrame: CGRect
    let bottomEdge: CGFloat
    
    var body: some View {
        Canvas { context, _ in
            let geometry = CameraZoomDialGeometry(zoomFrame: zoomFrame)
            let clipFrame = CGRect(x: zoomFrame.minX, y: geometry.dialFrame.minY,
                                   width: zoomFrame.width,
                                   height: max(0, bottomEdge - geometry.dialFrame.minY))
            context.clip(to: Path(clipFrame))
            let wheel = CGRect(x: geometry.wheelCenter.x - geometry.radius,
                               y: geometry.wheelCenter.y - geometry.radius,
                               width: geometry.radius * 2, height: geometry.radius * 2)
            var background = Path(ellipseIn: wheel)
            background.addRect(CGRect(x: zoomFrame.minX, y: zoomFrame.maxY,
                                      width: zoomFrame.width,
                                      height: max(0, bottomEdge - zoomFrame.maxY)))
            // Fill once so the circular cap and lower area have the same opacity.
            context.fill(background, with: .color(.black.opacity(0.72)))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Dial hit area

private struct CameraZoomDialShape: Shape {
    let zoomFrame: CGRect
    
    func path(in rect: CGRect) -> Path {
        let geometry = CameraZoomDialGeometry(zoomFrame: zoomFrame)
        let halfAngle = acos(max(-1, min(1, (geometry.radius - geometry.dialFrame.height) / geometry.radius)))
        var path = Path()
        path.addArc(center: geometry.wheelCenter, radius: geometry.radius,
                    startAngle: .radians(Double(-.pi / 2 - halfAngle)),
                    endAngle: .radians(Double(-.pi / 2 + halfAngle)), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Dial geometry

private struct CameraZoomDialGeometry {
    let zoomFrame: CGRect
    var radius: CGFloat { max(1, zoomFrame.width * 0.552) }
    var dialFrame: CGRect {
        let height = zoomFrame.width * 0.32
        return CGRect(x: zoomFrame.minX, y: zoomFrame.maxY - height,
                      width: zoomFrame.width, height: height)
    }
    var wheelCenter: CGPoint {
        CGPoint(x: zoomFrame.midX, y: dialFrame.minY + radius)
    }
    
    func angle(at point: CGPoint) -> CGFloat {
        atan2(point.x - wheelCenter.x, wheelCenter.y - point.y)
    }
}

// MARK: - Dial rendering

/// The visual wheel; its touch handling is supplied by the camera's gesture host.
private struct CameraZoomDialView: View {
    // MARK: - Properties
    
    let zoomFactor: CGFloat
    let zoomRange: ClosedRange<CGFloat>
    let zoomLenses: [CameraZoomLens]
    let zoomFrame: CGRect
    let rotation: CameraControlRotation
    
    // MARK: - Constants
    
    private static let pointerHalfWidth: CGFloat = 3
    
    // MARK: - Derived state
    
    private var scale: CameraZoomScale { CameraZoomScale(range: zoomRange) }
    private var factor: CGFloat { scale.clampedFactor(zoomFactor) }
    private var geometry: CameraZoomDialGeometry { CameraZoomDialGeometry(zoomFrame: zoomFrame) }
    private var radius: CGFloat { geometry.radius }
    private var dialFrame: CGRect { geometry.dialFrame }
    private var wheelCenter: CGPoint { geometry.wheelCenter }
    
    private var labelRotation: CGFloat {
        switch rotation.deviceOrientation {
        case .landscapeLeft: return .pi / 2
        case .landscapeRight: return -.pi / 2
        case .portraitUpsideDown, .faceDown: return .pi
        default: return 0
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Canvas { context, _ in
            context.clip(to: Path(dialFrame))
            
            let landmarks = scale.labelFactors(for: zoomLenses)
            let selectedLens = scale.selectedLens(for: factor, in: zoomLenses)
            let ticks = scale.tickFactors
            for tick in ticks {
                let isLandmark = landmarks.contains(tick)
                let isMajorTick = tick == tick.rounded() || isLandmark
                drawTick(angle: scale.angle(for: tick, relativeTo: factor),
                         color: .white.opacity(isMajorTick ? 1 : 0.2),
                         lineWidth: isLandmark ? 1 : 2.0 / 3.0, context: context)
            }
            for landmark in landmarks {
                let angle = scale.angle(for: landmark, relativeTo: factor)
                guard abs(angle) < .pi / 2 else { continue }
                if !ticks.contains(landmark) {
                    drawTick(angle: angle, color: .white, lineWidth: 1, context: context)
                }
                let visibility = min(max((abs(angle) - 0.08) / 0.14, 0), 1)
                // Only the number fades near the pointer; the lens caption keeps moving.
                let lens = lens(at: landmark)
                let subtitle = lens == selectedLens ? nil : lens?.focalLengthTitle
                drawText(scale.zoomTitle(for: landmark), subtitle: subtitle,
                         at: point(at: angle, radius: radius - 37),
                         rotation: angle + labelRotation, color: .white,
                         subtitleColor: .white.opacity(0.45),
                         titleVisibility: visibility, context: context)
            }
            
            let yellow = Color.yellow
            var pointer = Path()
            pointer.move(to: CGPoint(x: wheelCenter.x - Self.pointerHalfWidth, y: dialFrame.minY + 4))
            pointer.addLine(to: CGPoint(x: wheelCenter.x + Self.pointerHalfWidth, y: dialFrame.minY + 4))
            pointer.addLine(to: CGPoint(x: wheelCenter.x, y: dialFrame.minY + 14))
            pointer.closeSubpath()
            context.fill(pointer, with: .color(yellow))
            drawText(scale.zoomTitle(for: factor) + "×",
                     subtitle: selectedLens?.focalLengthTitle,
                     at: CGPoint(x: wheelCenter.x, y: dialFrame.minY + 36),
                     rotation: labelRotation, color: yellow, subtitleColor: yellow,
                     titleVisibility: 1, context: context)
        }
    }
    
    // MARK: - Drawing helpers
    
    private func point(at angle: CGFloat, radius: CGFloat) -> CGPoint {
        CGPoint(x: wheelCenter.x + sin(angle) * radius,
                y: wheelCenter.y - cos(angle) * radius)
    }
    
    private func drawTick(angle: CGFloat, color: Color, lineWidth: CGFloat, context: GraphicsContext) {
        let edgeVisibility = min(max((1.03 - abs(angle)) / 0.33, 0), 1)
        guard edgeVisibility > 0 else { return }
        let outerRadius = radius - 5
        // The pointer replaces the tick directly beneath it; neighboring ticks keep moving.
        guard abs(sin(angle) * outerRadius) > Self.pointerHalfWidth else { return }
        var tick = Path()
        tick.move(to: point(at: angle, radius: outerRadius))
        tick.addLine(to: point(at: angle, radius: outerRadius - 17))
        context.stroke(tick, with: .color(color.opacity(Double(edgeVisibility))), lineWidth: lineWidth)
    }
    
    private func lens(at factor: CGFloat) -> CameraZoomLens? {
        zoomLenses.first { scale.range.contains($0.factor) && abs($0.factor - factor) < 0.001 }
    }
    
    private func drawText(_ title: String, subtitle: String?, at position: CGPoint, rotation: CGFloat,
                          color: Color, subtitleColor: Color, titleVisibility: CGFloat,
                          context: GraphicsContext) {
        var textContext = context
        textContext.translateBy(x: position.x, y: position.y)
        textContext.rotate(by: .radians(Double(rotation)))
        let text = Text(title)
            .font(.system(size: 13 * (0.5 + titleVisibility * 0.5), weight: .regular))
            .monospacedDigit()
            .foregroundColor(color.opacity(Double(titleVisibility)))
        textContext.draw(text, at: .zero, anchor: .center)
        if let subtitle {
            let caption = Text(subtitle)
                .font(.system(size: 10))
                .monospacedDigit()
                .foregroundColor(subtitleColor)
            textContext.draw(caption, at: CGPoint(x: 0, y: 17), anchor: .center)
        }
    }
}
