import SwiftUI

// --- Protocols and Extensions (Unchanged: ScrollPickerItem, LocKey, measureLoc) ---
protocol ScrollPickerItem: Identifiable {
    var value: Int { get }
    var loc: CGRect { get set }
}
struct SignatureItem: Identifiable, ScrollPickerItem { // ... unchanged ... }
    let id = UUID()
    var value: Int
    var loc: CGRect = .zero
}
struct BeatItem: Identifiable, ScrollPickerItem { // ... unchanged ... }
    let id = UUID()
    var value: Int
    var loc: CGRect = .zero
}
struct LocKey: PreferenceKey { // ... unchanged ... }
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
extension View { // ... unchanged ... }
    func measureLoc(perform action: @escaping (CGRect) -> Void) -> some View {
        self.background(GeometryReader { geometry in
            Color.clear
                .preference(key: LocKey.self, value: geometry.frame(in: .global))
        })
        .onPreferenceChange(LocKey.self, perform: action)
    }
}


// --- Main View ---
struct TimeSignaturePicker: View {
    @Environment(ModelData.self) var modelData
    let signaturesData = Array(1...12)
    let beatsData = [2, 4, 8]
    @State private var signatureItems: [SignatureItem]
    @State private var beatItems: [BeatItem]
    @State private var centerX: CGFloat? = nil
    @State private var scrollViewWidth: CGFloat = 0
    @State private var centredSignature: SignatureItem? = nil
    @State private var centredBeat: BeatItem? = nil

    private let itemWidth: CGFloat = 110
    private let itemFontSize: CGFloat = 88
    private let itemSpacing: CGFloat = 25
    private let pickerHeightMultiplier: CGFloat = 1.5
    private let nonCenteredOpacity: Double = 0.4 // Adjust opacity for non-centered items

    init() {
        _signatureItems = State(initialValue: signaturesData.map { SignatureItem(value: $0) })
        _beatItems = State(initialValue: beatsData.map { BeatItem(value: $0) })
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Display HStack (Unchanged)
                HStack {
                    Text("Selected:")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Text("\(modelData.timeSignature[0])")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(width: 50, alignment: .trailing)
                        .id("signatureValueText")
                    Text("/")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text("\(modelData.timeSignature[1])")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(width: 50, alignment: .leading)
                        .id("beatValueText")

                }
                .padding(.top)
                .onChange(of: modelData.timeSignature[0]) { _, newValue in
                    if let matchingItem = signatureItems.first(where: { $0.value == newValue }), centredSignature?.id != matchingItem.id {
                         centredSignature = matchingItem
                    }
                }
                .onChange(of: modelData.timeSignature[1]) { _, newValue in
                     if let matchingItem = beatItems.first(where: { $0.value == newValue }), centredBeat?.id != matchingItem.id {
                         centredBeat = matchingItem
                     }
                }

                Spacer()

                // Signatures ScrollView (Unchanged call structure)
                pickerScrollView(
                    items: $signatureItems,
                    centredItem: $centredSignature,
                    centerX: centerX,
                    itemWidth: itemWidth,
                    scrollViewWidth: scrollViewWidth,
                    initialValue: modelData.timeSignature[0],
                    updateModel: { newValue in
                        if modelData.timeSignature[0] != newValue { modelData.timeSignature[0] = newValue }
                    }
                )

                // Beats ScrollView (Unchanged call structure)
                pickerScrollView(
                    items: $beatItems,
                    centredItem: $centredBeat,
                    centerX: centerX,
                    itemWidth: itemWidth,
                    scrollViewWidth: scrollViewWidth,
                    initialValue: modelData.timeSignature[1],
                    updateModel: { newValue in
                         if modelData.timeSignature[1] != newValue { modelData.timeSignature[1] = newValue }
                    }
                )

                Spacer()
                Spacer()
            }
            // Geometry/Background/Overlay/onChange (Unchanged)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hue: 0, saturation: 0, brightness: 0.13))
            .ignoresSafeArea()
            .overlay(
                 Color.clear
                    .frame(width: 1, height: geometry.size.height)
                    .measureLoc { loc in // ... unchanged ... }
                         let potentialCenterX = loc.midX
                        if centerX == nil || abs(potentialCenterX - (centerX ?? 0)) > 0.1 {
                            DispatchQueue.main.async {
                                centerX = potentialCenterX
                                if scrollViewWidth == 0 {
                                     scrollViewWidth = geometry.size.width
                                }
                            }
                        }
                    }
            )
            .onChange(of: geometry.size) { _, newSize in // ... unchanged ... }
                 DispatchQueue.main.async {
                     scrollViewWidth = newSize.width
                     centerX = nil
                 }
            }
        }
        .onAppear {
             syncInitialState()
        }
    }

    // syncInitialState (Unchanged)
    private func syncInitialState() { // ... unchanged ... }
        if let initialSig = signatureItems.first(where: { $0.value == modelData.timeSignature[0] }) {
            centredSignature = initialSig
        } else {
            centredSignature = signatureItems.first
            if let first = centredSignature { modelData.timeSignature[0] = first.value }
        }
         if let initialBeat = beatItems.first(where: { $0.value == modelData.timeSignature[1] }) {
            centredBeat = initialBeat
         } else {
            centredBeat = beatItems.first
            if let first = centredBeat { modelData.timeSignature[1] = first.value }
         }
    }


    // --- Reusable Picker ScrollView Component ---
    @ViewBuilder
    private func pickerScrollView<ItemType: ScrollPickerItem>(
        items: Binding<[ItemType]>,
        centredItem: Binding<ItemType?>,
        centerX: CGFloat?,
        itemWidth: CGFloat,
        scrollViewWidth: CGFloat,
        initialValue: Int,
        updateModel: @escaping (Int) -> Void
    ) -> some View {
        // Padding calculation ensures first/last items can center align
        let halfScrollViewWidth = scrollViewWidth / 2
        let padding = max(0, halfScrollViewWidth - (itemWidth / 2))

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    Spacer(minLength: padding)

                    ForEach(items) { $item in
                        let isCentered = centredItem.wrappedValue?.id == item.id
                        Text("\(item.value)")
                            .font(.system(size: itemFontSize))
                            // Bolding still depends on being centered
                            .fontWeight(isCentered ? .bold : .regular)
                            // --- CHANGE: Always white, adjust opacity ---
                            .foregroundStyle(.white) // Base color is white
                            .opacity(isCentered ? 1.0 : nonCenteredOpacity) // Adjust opacity
                            // --- End Change ---
                            .frame(width: itemWidth, height: itemFontSize * pickerHeightMultiplier)
                            .id(item.id)
                            .measureLoc { loc in // --- measureLoc logic unchanged ---
                                // 1. Update Item's Location
                                guard let index = items.wrappedValue.firstIndex(where: { $0.id == item.id }) else { return }
                                if items.wrappedValue[index].loc != loc {
                                    DispatchQueue.main.async {
                                        if items.wrappedValue.indices.contains(index) {
                                            items.wrappedValue[index].loc = loc
                                        }
                                    }
                                }

                                // 2. Check for Centering
                                guard let currentCenterX = centerX else { return }
                                var closestItem: ItemType? = nil
                                var minDistance = CGFloat.infinity
                                for currentItem in items.wrappedValue {
                                    if currentItem.loc != .zero {
                                        let currentItemCenter = currentItem.loc.midX
                                        let currentDistance = abs(currentItemCenter - currentCenterX)
                                        if currentDistance < minDistance {
                                            minDistance = currentDistance
                                            closestItem = currentItem
                                        }
                                    }
                                }

                                // 3. Update Internal UI State and Trigger Model Update
                                if let foundClosestItem = closestItem, centredItem.wrappedValue?.id != foundClosestItem.id {
                                    DispatchQueue.main.async {
                                        if centredItem.wrappedValue?.id != foundClosestItem.id {
                                            withAnimation(.easeOut(duration: 0.15)) {
                                                centredItem.wrappedValue = foundClosestItem
                                            }
                                            updateModel(foundClosestItem.value)
                                        }
                                    }
                                } else if closestItem == nil && centredItem.wrappedValue != nil {
                                     // Optional clear
                                }
                            } // End measureLoc
                    } // End ForEach

                    Spacer(minLength: padding)
                } // End HStack
                .if(major >= 17) { view in
                    view.scrollTargetLayout()
                }

            } // End ScrollView
            .frame(height: itemFontSize * pickerHeightMultiplier)
            .if(major >= 17) { view in
                // This behavior aligns the center of the item (`Text` view) specified in the
                // scrollTargetLayout (the HStack arranges them) with the center of the ScrollView's frame.
                // The padding ensures the first and last items can reach this center alignment point.
                // Therefore, snapping to the ends works correctly with this setup.
                view.scrollTargetBehavior(.viewAligned)
            }
            // --- onAppear / onChange logic for initial scroll unchanged ---
            .onAppear { // ... unchanged ... }
                 if let initialItem = items.wrappedValue.first(where: { $0.value == initialValue }) {
                    DispatchQueue.main.async {
                        proxy.scrollTo(initialItem.id, anchor: .center)
                        if centredItem.wrappedValue?.id != initialItem.id { centredItem.wrappedValue = initialItem }
                    }
                 } else {
                     if let firstItem = items.wrappedValue.first {
                         DispatchQueue.main.async {
                            proxy.scrollTo(firstItem.id, anchor: .center)
                             if centredItem.wrappedValue?.id != firstItem.id {
                                centredItem.wrappedValue = firstItem
                                updateModel(firstItem.value) // Update model if defaulted
                             }
                         }
                     }
                 }
            }
            .onChange(of: initialValue) { _, newValue in // ... unchanged ... }
                 if let targetItem = items.wrappedValue.first(where: { $0.value == newValue }) {
                     if centredItem.wrappedValue?.id != targetItem.id {
                          DispatchQueue.main.async {
                              withAnimation {
                                 proxy.scrollTo(targetItem.id, anchor: .center)
                              }
                              centredItem.wrappedValue = targetItem
                          }
                     }
                 }
            }
        } // End ScrollViewReader
    }

    // --- iOS Version Helper (unchanged) ---
    private var major: Int { // ... unchanged ... }
        if #available(iOS 17, *) { return 17 }
        if #available(iOS 16, *) { return 16 }
        return 15
    }
}

// --- Conditional Modifier (unchanged) ---
extension View { // ... unchanged ... }
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}


// --- Preview ---
#Preview {
    TimeSignaturePicker()
        .environment(ModelData())
}
