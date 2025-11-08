/// Danh sách các endpoint API được sử dụng trong ứng dụng. 
/// Các giá trị này dựa trên file `api_routes.json` từ backend Laravel và 
/// được chuyển sang dạng RESTful (điền thêm tiền tố /api khi cần).
class ApiEndpoints {
  // Đường dẫn cơ sở (sẽ được lấy từ cấu hình hoặc .env trong thực tế)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // User
  static const String users = '/users';
  static String user(int id) => '/users/$id';

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

  // Services
  static const String services = '/services';
  static String service(int id) => '/services/$id';

  // Amenities
  static const String amenities = '/amenities';
  static String amenity(int id) => '/amenities/$id';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(int id) => '/bookings/$id';

  // Bills
  static const String bills = '/bills';
  static String bill(int id) => '/bills/$id';
  static String payBill(int id) => '/bills/$id/pay';

  // Repairs
  static const String repairs = '/repairs';
  static String repair(int id) => '/repairs/$id';

  // Notifications
  static const String notifications = '/notifications';
  static String notification(int id) => '/notifications/$id';
}