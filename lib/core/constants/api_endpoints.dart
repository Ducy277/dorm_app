/// Danh sách các endpoint API được sử dụng trong ứng dụng.
/// Các giá trị này dựa trên file `api_routes.json` từ backend Laravel và
/// được chuyển sang dạng RESTful (điền thêm tiền tố /api khi cần).
class ApiEndpoints {
  // Đường dẫn cơ sở (sẽ được lấy từ cấu hình hoặc .env trong thực tế)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // User
  static const String users = '/users';
  static String user(int id) => '/users/$id';
  static const String me = '/me';
  static const String profile = '/profile';

  // Branches
  static const String branches = '/branches';
  static String branch(int id) => '/branches/$id';
  static String floorsByBranch(int id) => '/branches/$id/floors';

  // Floors
  static const String floors = '/floors';
  static String floor(int id) => '/floors/$id';

  // Rooms
  static const String rooms = '/rooms';
  static String room(int id) => '/rooms/$id';
  static String roomImages(int id) => '/rooms/$id/images';
  static String roomServices(int id) => '/rooms/$id/services';
  static String roomAmenities(int id) => '/rooms/$id/amenities';
  static String roomReviews(int id) => '/rooms/$id/reviews';

  // My room
  static const String myRoom = '/rooms/my';

  // Services
  static const String services = '/services';
  static String service(int id) => '/services/$id';

  // Amenities
  static const String amenities = '/amenities';
  static String amenity(int id) => '/amenities/$id';

  // Reviews
  static const String reviews = '/reviews';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingsMy = '/bookings/my';
  static const String bookingsReturn = '/bookings/return';
  static String booking(int id) => '/bookings/$id';

  // Bills
  static const String bills = '/bills';
  static const String billsMy = '/bills/my';
  static String bill(int id) => '/bills/$id';
  static String payBill(int id) => '/bills/$id/pay';
  static String vnpayRedirect(int billId) => '/vnpay/redirect/$billId';

  // Repairs
  static const String repairs = '/repairs';
  static const String repairsMy = '/repairs/my';
  static String repair(int id) => '/repairs/$id';

  // Notifications
  static const String notifications = '/notifications';
  static String notification(int id) => '/notifications/$id';
}
