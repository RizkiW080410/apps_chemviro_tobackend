import 'package:get/get.dart';
import '../pages/login.dart';
import '../pages/home.dart';
import '../pages/welcome.dart';
import '../pages/order.dart';
import '../pages/profile_page.dart';
import '../pages/so_page.dart';
import '../pages/po_page.dart';
import '../pages/co_page.dart';
import '../pages/client_page.dart';
import '../pages/create_client_page.dart';
import '../pages/detail_co_pages.dart';
import '../pages/detail_po_page.dart';
import '../pages/detail_so_page.dart';
import '../pages/edit_order_page.dart';

class Routes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const order = '/order';
  static const salesOrder = '/sales-order';
  static const purchaseOrder = '/purchase-order';
  static const cancelOrder = '/cancel-order';
  static const client = '/client';
  static const createClient = '/client/create';
  static const detailCancelOrder = '/detail-cancel-order';
  static const detailSalesOrder = '/detail-sales-order';
  static const detailPurchaseOrder = '/detail-purchase-order';
  static const editOrder = '/edit-order';
}

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomePage(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.order,
      page: () => OrderPage(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.client,
      page: () => const ClientPage(),
    ),
    GetPage(
      name: Routes.createClient,
      page: () => const CreateClientPage(),
    ),
    GetPage(
      name: Routes.salesOrder,
      page: () => const SalesOrderPage(),
    ),
    GetPage(
      name: Routes.purchaseOrder,
      page: () => const PurchaseOrderPage(),
    ),
    GetPage(
      name: Routes.cancelOrder,
      page: () => const CancelOrderPage(),
    ),
    GetPage(
      name: Routes.detailCancelOrder,
      page: () => CancelOrderDetailPage(order: Get.arguments),
    ),
    GetPage(
      name: Routes.detailSalesOrder,
      page: () => SalesOrderDetailPage(order: Get.arguments),
    ),
    GetPage(
      name: Routes.detailPurchaseOrder,
      page: () => PurchaseOrderDetailPage(order: Get.arguments),
    ),
    GetPage(
      name: Routes.editOrder,
      page: () => EditOrderPage(order: Get.arguments),
    ),
  ];
}
