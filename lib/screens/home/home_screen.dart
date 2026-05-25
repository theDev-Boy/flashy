import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/home/flashy_disk_card.dart';
import '../../widgets/home/device_locations_list.dart';
import '../../widgets/home/onboarding_guide_banner.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../constants/app_strings.dart';
import '../../providers/drive_provider.dart';
import '../../providers/selection_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driveProvider.notifier).fetchQuota();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  ref.read(driveProvider.notifier).fetchQuota();
                  break;
                case 'select':
                  ref.read(selectionProvider.notifier).clearSelection();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'select', child: Text('Select Items')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(driveProvider.notifier).fetchQuota();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  const FlashyDiskCard(),
                  const OnboardingGuideBanner(),
                  const DeviceLocationsList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
