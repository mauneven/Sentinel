import SwiftUI
import AppKit

struct IntervalSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Int>
    let minuteLabel: String
    let isEnabled: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(range.lowerBound) \(minuteLabel)")
                Spacer()
                Text("30 \(minuteLabel)")
                Spacer()
                Text("\(range.upperBound) \(minuteLabel)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            GeometryReader { geometry in
                let width = max(geometry.size.width, 1)

                ZStack(alignment: .topLeading) {
                    TickMarksView(width: width, range: range)
                        .frame(height: 10)
                        .offset(y: 8)

                    NativeSliderRepresentable(value: $value, range: range, isEnabled: isEnabled)
                        .frame(height: 18)

                    Text("\(Int(value.rounded()))")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .position(x: min(max(thumbX(in: width), 16), width - 16), y: 32)
                }
            }
            .frame(height: 38)
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
}

private struct TickMarksView: View {
    let width: CGFloat
    let range: ClosedRange<Int>

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(tickValues, id: \.self) { mark in
                Rectangle()
                    .fill(.white.opacity(0.35))
                    .frame(width: 1, height: isMajor(mark) ? 8 : 4)
                    .offset(x: x(for: mark), y: 0)
            }
        }
    }

    private var tickValues: [Int] {
        var values = [range.lowerBound]
        var current = 5
        while current <= range.upperBound {
            if current != range.lowerBound {
                values.append(current)
            }
            current += 5
        }
        if !values.contains(range.upperBound) {
            values.append(range.upperBound)
        }
        return values.sorted()
    }

    private func isMajor(_ value: Int) -> Bool {
        value == range.lowerBound || value % 10 == 0 || value == range.upperBound
    }

    private func x(for value: Int) -> CGFloat {
        let minValue = CGFloat(range.lowerBound)
        let maxValue = CGFloat(range.upperBound)
        guard maxValue > minValue else { return 0 }
        let clamped = min(max(CGFloat(value), minValue), maxValue)
        return ((clamped - minValue) / (maxValue - minValue)) * width
    }
}

private struct NativeSliderRepresentable: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Int>
    let isEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(
            value: value,
            minValue: Double(range.lowerBound),
            maxValue: Double(range.upperBound),
            target: context.coordinator,
            action: #selector(Coordinator.valueChanged(_:))
        )
        slider.isContinuous = true
        slider.allowsTickMarkValuesOnly = false
        slider.numberOfTickMarks = 0
        slider.controlSize = .regular
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        nsView.minValue = Double(range.lowerBound)
        nsView.maxValue = Double(range.upperBound)
        let clamped = min(max(value, Double(range.lowerBound)), Double(range.upperBound))
        if abs(nsView.doubleValue - clamped) > 0.001 {
            nsView.doubleValue = clamped
        }
        nsView.isEnabled = isEnabled
    }

    final class Coordinator: NSObject {
        @Binding var value: Double

        init(value: Binding<Double>) {
            _value = value
        }

        @objc func valueChanged(_ sender: NSSlider) {
            value = sender.doubleValue.rounded()
        }
    }
}
