# User Map Trace App

Flutter tabanlı, kullanıcı konum takibi ve rota kaydetme uygulaması. Uygulama, kullanıcıların hareketlerini gerçek zamanlı olarak takip eder, rotalarını kaydeder ve istatistikler sunar.

## 🚀 Özellikler

- **Gerçek Zamanlı Konum Takibi**: Kullanıcının konumunu gerçek zamanlı olarak haritada gösterir
- **Arka Plan Servisi**: Uygulama kapalıyken bile konum takibini sürdürür
- **Rota Kaydetme**: Takip edilen rotaları kaydeder ve daha sonra görüntülenebilir
- **Rota Detayları**: Kaydedilmiş rotaların detaylı bilgilerini gösterir (mesafe, süre, hız vb.)
- **Harita Görüntüleme**: Interaktif harita üzerinde rotaları ve konumları görüntüler
- **İstatistikler**: Yolculuk süresi, mesafe ve hız bilgileri

## 🛠️ Kurulum

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd user_map_trace_app
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Code generation işlemlerini çalıştırın:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## 📱 Platform Özel Ayarlar

### Android

- `AndroidManifest.xml` dosyasında konum izinleri tanımlıdır
- Arka plan konum servisi için gerekli izinler mevcuttur

### iOS

- `Info.plist` dosyasında konum izinleri tanımlıdır
- Arka plan konum güncellemeleri için `UIBackgroundModes` ayarlanmıştır

## 🏗️ Mimari

Uygulama Clean Architecture prensiplerine uygun olarak geliştirilmiştir:

- **Presentation Layer**: BLoC pattern ile state management
- **Data Layer**: Repository pattern ile veri yönetimi
- **Domain Layer**: Business logic ve modeller
- **Infrastructure**: Background services, location services

### Kullanılan Teknolojiler

- **State Management**: BLoC (flutter_bloc)
- **Routing**: Auto Route
- **Local Storage**: Hive
- **Dependency Injection**: Get It
- **Harita**: Flutter Map
- **Konum Servisleri**: Geolocator, Geocoding
- **Arka Plan Servisi**: Flutter Background Service
- **Network**: Dio

## 📁 Proje Yapısı

```
lib/
├── app/
│   ├── common/           # Ortak kullanılan bileşenler
│   │   ├── constants/    # Sabitler (renkler, stringler, tema)
│   │   ├── functions/    # Yardımcı fonksiyonlar
│   │   ├── get_it/       # Dependency injection
│   │   ├── infrastructure/ # Altyapı servisleri
│   │   └── router/       # Routing yapılandırması
│   └── features/         # Feature bazlı modüller
│       ├── data/         # Data katmanı
│       └── presentation/ # Presentation katmanı
│           ├── home/     # Ana ekran
│           ├── settings/ # Ayarlar ve kaydedilmiş rotalar
│           └── splash/  # Splash ekranı
└── core/                 # Core utilities
    ├── extensions/        # Extension'lar
    ├── logger/           # Logging
    └── result/           # Result pattern
```

## 🔧 Geliştirme

### Code Generation

Proje, code generation kullanır. Değişikliklerden sonra şu komutu çalıştırın:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode için:

```bash
flutter pub run build_runner watch
```

### Linting

Proje `flutter_lints` kullanır. Lint kontrolü için:

```bash
flutter analyze
```

## 📝 Lisans

Bu proje özel bir projedir ve lisanslanmamıştır.

## 👤 Geliştirici

Doğukan Özgür Yılmaz
