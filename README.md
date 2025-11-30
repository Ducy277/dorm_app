# QL_KTX Flutter App

Ứng dụng Flutter quản lý ký túc xá (sinh viên đặt phòng, hóa đơn, thông báo, sửa chữa...).

## Yêu cầu môi trường
- Flutter 3.24+ (stable)
- Dart 3.5+
- Android Studio (để build mobile)
- Ngrok hoặc endpoint backend sẵn (REST API)

## Thiết lập nhanh
```bash
git clone <repo-url>
cd ql_ktx
flutter pub get
```

## Chạy ứng dụng
- Android/iOS: `flutter run`
- Web: `flutter run -d chrome`

### Cấu hình API base URL (tùy chọn)
API mặc định lấy từ `ApiEndpoints.baseUrl` (ngrok). Muốn trỏ về server khác:
```bash
flutter run --dart-define=API_BASE_URL=https://your-server/api/v1
```
Hoặc với build web:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://your-server/api/v1
```

## Kiến trúc & thư mục
- `lib/core`: constants, theme, error handling, utils, widgets dùng chung.
- `lib/data`: `datasources/api_service.dart` (Dio + token), `models`, `repositories` gọi API.
- `lib/domain`: `entities` cho các model đã chuẩn hóa.
- `lib/presentation`: BLoC theo tính năng (`presentation/bloc/<feature>`), routes (GoRouter), screens/widgets.

## State management & DI
- BLoC + Equatable cho events/states.
- MultiRepositoryProvider + MultiBlocProvider khởi tạo trong `lib/app.dart`.
- Routing: GoRouter trong `presentation/routes/app_router.dart`.

## Lưu ý build
- Nếu đổi endpoint cần đảm bảo server hỗ trợ HTTPS hoặc cấu hình ngrok phù hợp.
- Khi build iOS cần cấu hình team/signing trong Xcode.

## Scripts hữu ích
- `flutter pub get` : cài dependency.
- `flutter pub outdated` : kiểm tra version gói.
- `flutter analyze` : phân tích static.
