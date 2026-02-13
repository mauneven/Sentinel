import SwiftUI

struct IntervalSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Int>
    let marks: [Int]
    let minuteLabel: String
    let isEnabled: Bool

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 14

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                let width = max(geometry.size.width, 1)
                let x = thumbX(in: width)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.18))
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(isEnabled ? Color.accentColor : .secondary.opacity(0.3))
                        .frame(width: x, height: trackHeight)

                    ForEach(marks, id: \.self) { mark in
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .position(x: markX(mark, in: width), y: trackHeight / 2)
                    }

                    Circle()
                        .fill(isEnabled ? Color.accentColor : .secondary)
                        .frame(width: thumbSize, height: thumbSize)
                        .position(x: x, y: trackHeight / 2)

                    Text("\(Int(value.rounded())) \(minuteLabel)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .position(x: min(max(x, 36), width - 36), y: 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            guard isEnabled else { return }
                            let clampedX = min(max(drag.location.x, 0), width)
                            let percent = clampedX / width
                            let rawValue = Double(range.lowerBound) + percent * Double(range.upperBound - range.lowerBound)
                            value = min(max(rawValue.rounded(), Double(range.lowerBound)), Double(range.upperBound))
                        }
                )
            }
            .frame(height: 32)

            HStack {
                ForEach(marks, id: \.self) { mark in
                    Text("\(mark)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .opacity(isEnabled ? 1 : 0.6)
    }

    private func thumbX(in width: CGFloat) -> CGFloat {
        let minValue = Double(range.lowerBound)
        let maxValue = Double(range.upperBound)
        guard maxValue > minValue else { return 0 }
        let clamped = min(max(value, minValue), maxValue)
        let percent = (clamped - minValue) / (maxValue - minValue)
        return CGFloat(percent) * width
    }

    private func markX(_ mark: Int, in width: CGFloat) -> CGFloat {
        let minValue = CGFloat(range.lowerBound)
        let maxValue = CGFloat(range.upperBound)
        guard maxValue > minValue else { return 0 }
        let clamped = min(max(CGFloat(mark), minValue), maxValue)
        return ((clamped - minValue) / (maxValue - minValue)) * width
    }
}
