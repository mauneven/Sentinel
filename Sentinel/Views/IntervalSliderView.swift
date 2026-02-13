import SwiftUI
import AppKit

struct IntervalSliderView: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Int>
    let tickStep: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(value: value,
                              minValue: Double(range.lowerBound),
                              maxValue: Double(range.upperBound),
                              target: context.coordinator,
                              action: #selector(Coordinator.valueChanged(_:)))
        slider.isContinuous = true
        slider.numberOfTickMarks = ((range.upperBound - range.lowerBound) / tickStep) + 1
        slider.tickMarkPosition = .below
        slider.allowsTickMarkValuesOnly = false
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        nsView.minValue = Double(range.lowerBound)
        nsView.maxValue = Double(range.upperBound)
        nsView.numberOfTickMarks = ((range.upperBound - range.lowerBound) / tickStep) + 1
        nsView.tickMarkPosition = .below
        nsView.doubleValue = min(max(value, Double(range.lowerBound)), Double(range.upperBound))
    }

    class Coordinator: NSObject {
        @Binding var value: Double

        init(value: Binding<Double>) {
            _value = value
        }

        @objc func valueChanged(_ sender: NSSlider) {
            value = sender.doubleValue
        }
    }
}
