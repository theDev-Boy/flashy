import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/file_browser/file_browser_screen.dart';
import 'screens/file_browser/flashy_disk_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/transfers/transfers_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/account_settings_screen.dart';
import 'screens/preview/image_preview_screen.dart';
import 'screens/preview/video_preview_screen.dart';
import 'screens/preview/audio_preview_screen.dart';
import 'screens/preview/text_preview_screen.dart';
import 'screens/preview/pdf_preview_screen.dart';
import 'screens/preview/archive_preview_screen.dart';
import 'widgets/flashy_disk/upload_popup.dart';

class FlashyApp extends ConsumerStatefulWidget {
  const FlashyApp({super.key});

  @override
  ConsumerState<FlashyApp> createState() => _FlashyAppState();
}

class _FlashyAppState extends ConsumerState<FlashyApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
    ref.listen(authProvider, (prev, next) {
      if (prev?.isAuthenticated != next.isAuthenticated) {
        _routerRefreshNotifier.notify();
      }
    });
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: _routerRefreshNotifier,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoginRoute) return '/login';
        if (isLoggedIn && isLoginRoute) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => ScaffoldWithNavBar(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/transfers',
              name: 'transfers',
              builder: (context, state) => const TransfersScreen(),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/local/:path',
          name: 'localBrowser',
          builder: (context, state) {
            final encodedPath = state.pathParameters['path'] ?? '/';
            final path = Uri.decodeComponent(encodedPath);
            return FileBrowserScreen(initialPath: path);
          },
        ),
        GoRoute(
          path: '/flashy-disk',
          name: 'flashyDiskRoot',
          builder: (context, state) => const FlashyDiskScreen(),
        ),
        GoRoute(
          path: '/flashy-disk/:folderId',
          name: 'flashyDiskFolder',
          builder: (context, state) {
            final folderId = state.pathParameters['folderId'];
            return FlashyDiskScreen(folderId: folderId);
          },
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/settings/account',
          name: 'accountSettings',
          builder: (context, state) => const AccountSettingsScreen(),
        ),
        GoRoute(
          path: '/preview',
          name: 'preview',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final type = extra?['type'] as String? ?? 'image';
            final path = extra?['path'] as String? ?? '';
            final name = extra?['name'] as String? ?? 'File';
            final isCloud = extra?['isCloud'] as bool? ?? false;

            switch (type) {
              case 'video':
                return VideoPreviewScreen(
                  videoPath: path,
                  fileName: name,
                  isCloudFile: isCloud,
                );
              case 'audio':
                return AudioPreviewScreen(
                  filePath: path,
                  fileName: name,
                  isCloudFile: isCloud,
                );
              case 'text':
                return TextPreviewScreen(
                  filePath: path,
                  fileName: name,
                );
              case 'pdf':
                return PdfPreviewScreen(
                  filePath: path,
                  fileName: name,
                  isCloudFile: isCloud,
                );
              case 'archive':
                return ArchivePreviewScreen(
                  filePath: path,
                  fileName: name,
                );
              case 'image':
              default:
                return ImagePreviewScreen(
                  imagePath: path,
                  fileName: name,
                  isCloudFile: isCloud,
                );
            }
          },
        ),
      ],
    );
  }

  /// A simple notifier to trigger router refresh from auth state changes.
  final _routerRefreshNotifier = _RouterRefreshNotifier();

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeState.accentColor),
      darkTheme: AppTheme.darkTheme(themeState.accentColor),
      themeMode: themeState.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const UploadPopup(),
          ],
        );
      },
    );
  }
}

/// A simple Listenable that can be used with GoRouter's refreshListenable.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/transfers')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/transfers');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.tabHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert_outlined),
            selectedIcon: Icon(Icons.swap_vert),
            label: AppStrings.tabTransfers,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }
}
