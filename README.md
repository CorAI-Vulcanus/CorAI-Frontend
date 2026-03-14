# CorAI - iOS App for Heart Monitoring

Aplicación iOS de monitoreo cardíaco en tiempo real, construida con SwiftUI.

## Características

- 📈 Visualización en vivo de ECG
- 💓 Métricas cardíacas (BPM, SpO₂, variabilidad, presión arterial)
- 🔔 Alertas y análisis inteligente

## Arquitectura

MVVM

```
CorAI/
├── App/              # Punto de entrada
├── Core/
│   ├── Components/   # Vistas reutilizables (ECGChartView, MetricCard)
│   ├── Networking/   # Cliente API y endpoints
│   └── Theme/        # Colores, tipografía, espaciado
├── Features/
│   └── Home/         # Pantalla principal (Model, View, ViewModel, Repository)
└── Navigation/       # Tab bar principal
```

## Requisitos

- iOS 17.0+
- Xcode 16+
- Swift 5.9+

## Instalación

```bash
git clone https://github.com/tu-usuario/CorAI-Frontend.git
cd CorAI-Frontend
open CorAI.xcodeproj
```

## Licencia

Ver [LICENSE](LICENSE).
