/// Tiện ích ghi log đơn giản.
class Logger {
  static void log(String message) {
    // Trong môi trường thực tế có thể sử dụng package logging
    // Ở đây đơn giản chỉ in ra console để debug.
    // ignore: avoid_print
    print(message);
  }
}