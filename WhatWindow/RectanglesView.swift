import SwiftUI

struct RectanglesView<ID: Hashable>: View {
    let roundedRectangle = RoundedRectangle(cornerSize: .init(width: 10, height: 10), style: .continuous)

    let rectangles: [IdentifiableRectangle]
    let aspect: CGFloat
    @Binding var selection: ID?
    
    init(rectangles: [IdentifiableRectangle], selection: Binding<ID?>) {
        (self.rectangles, aspect) = Self.normalize(objects: rectangles)
        _selection = selection
    }
    
    var body: some View {
        GeometryReader { proxy in
            ForEach(rectangles) { object in
                let rect = object.rectangle
                let destinationSize = rect.size * proxy.size
                let destination = rect.origin * [proxy.size.width, proxy.size.height]
                roundedRectangle
                    .foregroundStyle(.windowBackground.opacity(0.85))
                    .frame(width: destinationSize.width, height: destinationSize.height)
                    .position(destination)
                    .shadow(
                        color: .black
                            .opacity(max(0.2, CGFloat(50) / (destinationSize.min()+50))),
                        radius: 20
                    )
                    .onTapGesture {
                        selection = object.id
                    }
                if selection == object.id {
                    Group {
                        roundedRectangleStroke
                        roundedRectangleStroke
                            .mask {
                                LinearGradient(
                                    colors: [.white.opacity(0.01), .white.opacity(0.1)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading
                                ).padding(-2)
                            }
                            .zIndex(1)
                    }
                    .foregroundStyle(Color.accentColor)
                    .frame(width: destinationSize.width, height: destinationSize.height)
                    .position(destination)
                }

            }
        }.padding(2)
        .aspectRatio(aspect, contentMode: .fit)
    }
    
    var roundedRectangleStroke: some View {
        roundedRectangle.stroke(style: .init(lineWidth: 2))
    }
    
    static func normalize(objects: [IdentifiableRectangle]) -> ([IdentifiableRectangle], CGFloat) {
        var bottomRight = -CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
        for object in objects {
            let rectangle = object.rectangle
            bottomRight = pointwiseMax(bottomRight, CGPoint(x: rectangle.maxX, y: rectangle.maxY))
        }

        let rectangles = objects.map { object in
            let rect = object.rectangle
            let halfSize = rect.size/2
            let originOffset: CGPoint = [halfSize.width, halfSize.height]
            return IdentifiableRectangle(
                id: object.id,
                rectangle: CGRect(
                    origin: (rect.origin + originOffset) / bottomRight,
                    size: rect.size / [bottomRight.x, bottomRight.y]
                )
            )
        }
        return (rectangles, bottomRight.x / bottomRight.y)
    }
    
    struct IdentifiableRectangle: Identifiable {
        let id: ID
        let rectangle: CGRect
    }
}

#Preview {
    @Previewable @State var selection: Int? = 4
    RectanglesView(
        rectangles: [
            CGRect(x: 234.0, y: 111.0, width: 646.0, height: 418.0),
            CGRect(x: 263.0, y: 140.0, width: 646.0, height: 418.0),
            CGRect(x: 292.0, y: 169.0, width: 646.0, height: 418.0),
            CGRect(x: 321.0, y: 198.0, width: 646.0, height: 418.0),
            CGRect(x: 350.0, y: 227.0, width: 646.0, height: 418.0),
            CGRect(x: 379.0, y: 256.0, width: 646.0, height: 418.0),
            CGRect(x: 408.0, y: 285.0, width: 646.0, height: 418.0),
            CGRect(x: 437.0, y: 314.0, width: 646.0, height: 418.0),
            CGRect(x: 466.0, y: 343.0, width: 646.0, height: 418.0),
            CGRect(x: 582.0, y: 459.0, width: 646.0, height: 418.0),

            CGRect(x: 86.0, y: 44.0, width: 1920.0, height: 1175.0),
            CGRect(x: 0.0, y: 44.0, width: 1658.0, height: 1021.0),
            CGRect(x: 0.0, y: 44.0, width: 1920.0, height: 1175.0),
            CGRect(x: 29.0, y: 73.0, width: 1920.0, height: 1175.0),
            CGRect(x: 58.0, y: 44.0, width: 1920.0, height: 1175.0),
            CGRect(x: 1671.0, y: 0.0, width: 36.0, height: 43.0),
            CGRect(x: 1172.0, y: 44.0, width: 715.0, height: 796.0),

        ],
        selection: $selection
    ).padding()
}

extension RectanglesView {
    init<Object: Identifiable>(objects: [Object], selection: Binding<ID?>, rectangle: KeyPath<Object, CGRect>) where ID == Object.ID {
        self.init(
            rectangles: objects.map {
                IdentifiableRectangle(id: $0.id, rectangle: $0[keyPath: rectangle])
            },
            selection: selection
        )
    }
}

extension RectanglesView where ID == Int {
    init(rectangles: [CGRect], selection: Binding<Int?>) {
        self.init(
            rectangles: rectangles.enumerated().map { IdentifiableRectangle(id: $0, rectangle: $1) },
            selection: selection
        )
    }
}

extension CGSize: @retroactive Hashable {}
extension CGSize: @retroactive SIMD {
    public typealias MaskStorage = SIMD2<CGFloat.NativeType.SIMDMaskScalar>

    public subscript(index: Int) -> CGFloat {
        get {
            index == 0 ? width : height
        }
        set(newValue) {
            if index == 0 { width = newValue }
            else { height = newValue }
        }
    }

    public var scalarCount: Int { 2 }

    public typealias Scalar = CGFloat
}

extension CGPoint: @retroactive Hashable {}
extension CGPoint: @retroactive SIMD {
    public typealias MaskStorage = SIMD2<CGFloat.NativeType.SIMDMaskScalar>

    public subscript(index: Int) -> CGFloat {
        get {
            index == 0 ? x : y
        }
        set(newValue) {
            if index == 0 { x = newValue }
            else { y = newValue }
        }
    }

    public var scalarCount: Int { 2 }

    public typealias Scalar = CGFloat
}
