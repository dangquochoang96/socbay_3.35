abstract final class ApiEndpoints {
  // =========================
  // AUTH
  // =========================
  static const setOtp = '/auth/setOTP';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const userInfo = '/auth';
  static const forgotPassword = '/auth/fogotPassWord';

  // =========================
  // USER
  // =========================
  static const login = '/user/login';
  static const updateStaff = '/user/update-staff';
  static const updateUser = '/user/updateUser';
  static const userListStaff = '/user/listStaff';
  static const userSupport = '/user/support';
  static const userCheck = '/user/check';
  static const userNearest = '/user/nearest';
  static const userListSupporters = '/user/listSupporters';
  static const userLikeStaff = '/user/likeStaff';
  static const userUnlikeStaff = '/user/unlikeStaff';
  static const userRegister = '/user/register';
  static const userAddress = '/userAddress';
  static const userSearchList = '/user/searchUser_list';

  static String userById(Object? id) => '/user/$id';
  static String userProducts(Object? id) => '/user/listProduct/$id';
  static String userStaffDetail(Object? id) => '/user/staff-detail/$id';
  static String userHistory(Object? orderId) => '/user/history/$orderId';
  static String userDetailHistory(Object? orderId) =>
      '/user/detailHistory/$orderId';
  static String userUpdatePaymentStatus(Object? orderId) =>
      '/user/updatePaymentStatus/$orderId';
  static String userRate(Object? userId, Object? orderId) =>
      '/user/rate/$userId/$orderId';
  static String userChangePassword(Object? phone) =>
      '/user/$phone/changePassWord';

  // =========================
  // USER FAVORITES
  // =========================
  static const userFavorites = '/user/listFavorite';
  static const userFavoriteAdd = '/user/addFavorite';
  static const userFavoriteRemove = '/user/unFavorite';

  // =========================
  // NOTIFICATION
  // =========================
  static const notifications = '/notify';
  static const notificationList = '/notify/list';

  // =========================
  // SETTING / BANNER
  // =========================
  static const banners = '/setting/banner';

  // =========================
  // BLOG
  // =========================
  static const blogs = '/blog/list';
  static const geyserBlogs =
      'https://geysereco.com/api/blogs/category/san-pham-dich-vu-2';

  // =========================
  // SERVICE
  // =========================
  static const services = '/service';

  // =========================
  // UPLOAD
  // =========================
  static const uploadImage = '/uploadImage';
  static const orderUploadImage = '/socbay/order/upload-image';

  // =========================
  // PRODUCT
  // =========================
  static const products = '/product';
  static const productListAll = '/product/listProduct';
  static const productSearch = '/product/search';
  static const productListCate = '/product/listCate';

  static String productById(Object? id) => '/product/$id';

  // =========================
  // PRODUCT CATEGORY
  // =========================
  static const productCategory = '/product-category';

  static String productCategoryById(Object? id) => '/product-category/$id';

  // =========================
  // GIFT
  // =========================
  static const gifts = '/gift';
  static const giftReceive = '/gift/receive';

  static String giftList({bool isReceiveList = false}) =>
      isReceiveList ? '/gift/listReceive' : gifts;

  // =========================
  // FEEDBACK
  // =========================
  static const feedbacks = '/socbay/feedbacks';

  static String feedbacksByStaff(Object? staffId) =>
      '/socbay/feedbacks/get-list-feedback-by-staff/$staffId';
  static String feedbackById(Object? feedbackId) =>
      '/socbay/feedbacks/$feedbackId';
  static String feedbackUpdate(Object? feedbackId) =>
      '/socbay/feedbacks/update/$feedbackId';

  // =========================
  // TASK
  // =========================
  static const tasks = '/socbay/tasks';
  static const taskCreate = '/socbay/tasks/them';
  static const taskDelete = '/socbay/tasks/xoa';
  static const tasksPending = '/socbay/tasks/ton-dong';

  static String tasksByCustomer(Object? customerId) =>
      '/socbay/tasks/customer/$customerId';
  static String taskById(Object? id) => '/socbay/tasks/$id';
  static String taskEdit(Object? id) => '/socbay/tasks/edit/$id';

  // =========================
  // RENT TASK
  // =========================
  static const rentTasks = '/socbay/rent-tasks';
  static const rentTaskCreate = '/socbay/rent-tasks/them';
  static const rentTaskDelete = '/socbay/rent-tasks/xoa';
  static const rentTasksPending = '/socbay/rent-tasks/ton-dong';

  static String rentTasksByCustomer(Object? customerId) =>
      '/socbay/rent-tasks/customer/$customerId';
  static String rentTaskById(Object? id) => '/socbay/rent-tasks/$id';
  static String rentTaskEdit(Object? id) => '/socbay/rent-tasks/edit/$id';

  // =========================
  // ORDER
  // =========================
  static const orderCreate = '/socbay/order/them';
  static const orderSaveRepair = '/socbay/order/save-repair';
  static const orderByPhone = '/socbay/order/phone';
  static const listOrderRatingByStaff =
      '/socbay/order/get-list-order-rating-by-staff';

  static String orderListByCustomer(Object? customerId) =>
      '/socbay/order/list-order-by-customer/$customerId';
  static String orderListStaff(Object? staffId) =>
      '/socbay/order/order-list-staff/$staffId';
  static String orderListBySale(Object? saleId) =>
      '/socbay/order/order-list-bySale/$saleId';
  static String orderSalesIncome(Object? userId) =>
      '/socbay/order/sales-income/$userId';
  static String orderLastReplaceFilterCore(Object? userId) =>
      '/socbay/order/last-replace-filter-core/$userId';

  // =========================
  // Warehouse
  // =========================
  static String listWasehouseByUser(Object? userId) =>
      '/riha/listWasehouseByUser/$userId';
  static const retailOrder = '/retailOrder';
  static const createRetailOrder = '/retailOrder/createRetailOrder';
}
