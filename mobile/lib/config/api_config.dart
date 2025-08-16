class ApiConfig {
  // Production server URL - Vercel'de çalışan API
  static const String productionBaseUrl = 'https://bonavias-wb3a.vercel.app/api';
  static const String productionServerUrl = 'https://bonavias-wb3a.vercel.app';
  
  // Development server URL - ngrok ile internet'e açılan server
  static const String developmentBaseUrl = 'https://60b8fc7c8080.ngrok-free.app/api';
  static const String developmentServerUrl = 'https://60b8fc7c8080.ngrok-free.app';
  
  // Test server URL - test sunucusu için
  static const String testBaseUrl = 'https://test.your-domain.com/api';
  static const String testServerUrl = 'https://test.your-domain.com';
  
  // Şu anda kullanılan URL'ler (değiştirilebilir)
  // APK için production URL kullanın, geliştirme için development URL kullanın
  static const String baseUrl = productionBaseUrl;  // Vercel URL'ini kullanıyoruz!
  static const String serverUrl = productionServerUrl;  // Vercel URL'ini kullanıyoruz!
  
  // Environment detection
  static bool get isProduction => baseUrl.contains('https://') && !baseUrl.contains('localhost');
  static bool get isDevelopment => baseUrl.contains('localhost') || baseUrl.contains('192.168');
  static bool get isTest => baseUrl.contains('test.');
  
  // API Endpoints
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/products';
  static const String campaignsEndpoint = '/campaigns';
  static const String branchesEndpoint = '/branches';
  static const String storiesEndpoint = '/stories';
  static const String slidersEndpoint = '/sliders';
  static const String usersEndpoint = '/users';
  static const String ordersEndpoint = '/orders';
  
  // Image URL helper
  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$serverUrl$imagePath';
  }
  
  // Full API URL helper
  static String getApiUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
