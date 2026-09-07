import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/workspace_role.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/ai_assist_sheet.dart';
import '../../widgets/handshake_logo.dart';
import '../../widgets/language_selector_button.dart';
import '../cooperative/cooperative_dashboard_screen.dart';
import 'customer/customer_bookings_view.dart';
import 'customer/customer_home_view.dart';
import 'customer/customer_profile_view.dart';
import 'customer/customer_services_view.dart';
import 'worker/worker_appointments_view.dart';
import 'worker/worker_earnings_view.dart';
import 'worker/worker_home_view.dart';
import 'worker/worker_jobs_view.dart';
import 'worker/worker_profile_view.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  static const routeName = '/home';

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _customerTabIndex = 0;
  int _workerTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final activeRole = auth.activeRole;

    if (activeRole == WorkspaceRoleId.cooperative) {
      return const CooperativeDashboardScreen();
    }

    final isWorker = activeRole == WorkspaceRoleId.worker;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, isWorker),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),

        child: isWorker
            ? _buildWorkerBody(_workerTabIndex)
            : _buildCustomerBody(_customerTabIndex),
      ),
      floatingActionButtonLocation: isWorker
          ? null
          : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isWorker ? null : _buildCenterAiFab(context),
      bottomNavigationBar: isWorker
          ? _buildWorkerBottomNav(context)
          : _buildCustomerBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isWorker) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('menuTappedToast')),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HandshakeLogo(size: 24),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.tr('appName'),
              style: AppTypography.heading(fontSize: 17).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Notification bell with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 22),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('noNotifications')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        const LanguageSelectorButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCustomerBody(int index) {
    switch (index) {
      case 0:
        return const CustomerHomeView(key: ValueKey('cust_home'));
      case 1:
        return const CustomerBookingsView(key: ValueKey('cust_bookings'));
      case 2:
        return const CustomerServicesView(key: ValueKey('cust_services'));
      case 3:
        return const CustomerProfileView(key: ValueKey('cust_profile'));
      default:
        return const CustomerHomeView(key: ValueKey('cust_home'));
    }
  }

  Widget _buildWorkerBody(int index) {
    switch (index) {
      case 0:
        return const WorkerHomeView(key: ValueKey('worker_home'));
      case 1:
        return const WorkerJobsView(key: ValueKey('worker_jobs'));
      case 2:
        return const WorkerAppointmentsView(key: ValueKey('worker_apts'));
      case 3:
        return const WorkerEarningsView(key: ValueKey('worker_earnings'));
      case 4:
        return const WorkerProfileView(key: ValueKey('worker_profile'));
      default:
        return const WorkerHomeView(key: ValueKey('worker_home'));
    }
  }

  Widget _buildCenterAiFab(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onPressed: () => AiAssistSheet.show(context),
      ),
    );
  }

  Widget _buildCustomerBottomNav(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      padding: EdgeInsets.zero,
      elevation: 8,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: _navItem(
                icon: Icons.home,
                label: context.tr('navHome'),
                isSelected: _customerTabIndex == 0,
                onTap: () => setState(() => _customerTabIndex = 0),
              ),
            ),
            Expanded(
              child: _navItem(
                icon: Icons.calendar_month,
                label: context.tr('navBookings'),
                isSelected: _customerTabIndex == 1,
                onTap: () => setState(() => _customerTabIndex = 1),
              ),
            ),
            const SizedBox(width: 48), // Space for center FAB
            Expanded(
              child: _navItem(
                icon: Icons.grid_view,
                label: context.tr('navServices'),
                isSelected: _customerTabIndex == 2,
                onTap: () => setState(() => _customerTabIndex = 2),
              ),
            ),
            Expanded(
              child: _navItem(
                icon: Icons.person,
                label: context.tr('navProfile'),
                isSelected: _customerTabIndex == 3,
                onTap: () => setState(() => _customerTabIndex = 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _workerTabIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.poppins(fontSize: 11),
      elevation: 8,
      onTap: (i) => setState(() => _workerTabIndex = i),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: context.tr('navHome'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.work_outline),
          label: context.tr('navJobs'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          label: context.tr('navAppointments'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: context.tr('navEarnings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: context.tr('navProfile'),
        ),
      ],
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey.shade500,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
