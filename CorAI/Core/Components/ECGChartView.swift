import SwiftUI

// MARK: - ECG Chart View

/// Animated ECG waveform drawn with a SwiftUI `Path`.
/// Accepts an array of normalized sample values (0…1) and animates a scrolling effect.
struct ECGChartView: View {

    let samples: [Double]
    let lineColor: Color

    init(samples: [Double], lineColor: Color = .corTeal) {
        self.samples = samples
        self.lineColor = lineColor
    }

    var body: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height

            Path { path in
                guard samples.count > 1 else { return }

                let stepX = width / CGFloat(samples.count - 1)

                for (index, sample) in samples.enumerated() {
                    let x = CGFloat(index) * stepX
                    // Map sample (0…1) → y  (top = high value, bottom = low)
                    let y = height * (1.0 - CGFloat(sample))

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - ECG Data Generator

/// Generates realistic-looking simulated ECG (PQRST) waveform data.
enum ECGDataGenerator {

    /// Produce one PQRST complex (normalized to 0…1 range, baseline ~0.5).
    static func generateComplex(sampleCount: Int = 60) -> [Double] {
        var wave = [Double](repeating: 0.5, count: sampleCount)

        // Helper to build a Gaussian bump
        func gaussian(center: Double, sigma: Double, amplitude: Double) -> (Int) -> Double {
            return { i in
                let x = Double(i) / Double(sampleCount)
                return amplitude * exp(-pow(x - center, 2) / (2 * sigma * sigma))
            }
        }

        let pWave  = gaussian(center: 0.15, sigma: 0.04, amplitude: 0.08)
        let qWave  = gaussian(center: 0.28, sigma: 0.01, amplitude: -0.10)
        let rWave  = gaussian(center: 0.32, sigma: 0.015, amplitude: 0.45)
        let sWave  = gaussian(center: 0.36, sigma: 0.012, amplitude: -0.12)
        let tWave  = gaussian(center: 0.55, sigma: 0.05, amplitude: 0.12)

        for i in 0..<sampleCount {
            wave[i] = 0.5 + pWave(i) + qWave(i) + rWave(i) + sWave(i) + tWave(i)
        }

        return wave
    }

    /// Produce a running buffer of multiple complexes with slight noise.
    static func generateStream(complexes: Int = 4, samplesPerComplex: Int = 60) -> [Double] {
        var stream: [Double] = []
        for _ in 0..<complexes {
            let complex = generateComplex(sampleCount: samplesPerComplex)
            let noisy = complex.map { $0 + Double.random(in: -0.005...0.005) }
            stream.append(contentsOf: noisy)
        }
        return stream
    }
}

// MARK: - Preview

#Preview {
    ECGChartView(samples: ECGDataGenerator.generateStream())
        .frame(height: 120)
        .padding()
        .background(Color.corCardBackground)
}
