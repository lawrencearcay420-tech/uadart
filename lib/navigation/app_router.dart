import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clothingapp/screens/login/login_screen.dart';
import 'package:clothingapp/screens/home/home_screen.dart';
import 'package:clothingapp/screens/shop/shop_screen.dart';
import 'package:clothingapp/screens/checkout/checkout_screen.dart';
import 'package:clothingapp/screens/checkout/order_success_screen.dart';
import 'package:clothingapp/screens/orders/orders_screen.dart';
import 'package:clothingapp/screens/wishlist/wishlist_screen.dart';
import 'package:clothingapp/screens/account/account_screen.dart';
import 'package:clothingapp/screens/admin/admin_screen.dart';
import 'package:clothingapp/screens/product/product_detail_screen.dart';
import 'package:clothingapp/data/models/order.dart';
import 'package:clothingapp/providers/auth_provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router => GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loggedIn = authProvider.isAuthenticated;
      final routePath = state.uri.path;
      final loggingIn = routePath == '/login';
      final requiresAuthentication = {
        '/cart',
        '/orders',
        '/account',
        '/wishlist',
        '/order-success',
      }.contains(routePath);

      if (!loggedIn && requiresAuthentication) {
        return Uri(
          path: '/login',
          queryParameters: {'redirect': state.uri.toString()},
        ).toString();
      }
      if (loggedIn && loggingIn) {
        final destination = state.uri.queryParameters['redirect'];
        if (destination != null &&
            destination.startsWith('/') &&
            !destination.startsWith('//')) {
          return destination;
        }
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          redirectTo: state.uri.queryParameters['redirect'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/shop',
            name: 'shop',
            builder: (context, state) => ShopScreen(
              initialCategory: state.uri.queryParameters['category'] ?? 'All',
              initialSearch: state.uri.queryParameters['search'] ?? '',
            ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/order-success',
        name: 'order-success',
        builder: (context, state) => OrderSuccessScreen(
          order: state.extra is Order ? state.extra as Order : null,
        ),
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        redirect: (context, state) {
          if (!authProvider.isAdmin) {
            return '/';
          }
          return null;
        },
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
}

class ShellScaffold extends StatefulWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _getSelectedIndex() {
    final subloc = GoRouterState.of(context).uri.toString();
    switch (subloc) {
      case '/':
        return 0;
      case '/shop':
        return 1;
      case '/cart':
        return 2;
      case '/orders':
        return 3;
      case '/account':
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/shop');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _getSelectedIndex(),
        onTap: _onItemTapped,
      ),
    );
  }
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Bag'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
