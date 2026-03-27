import 'package:flutter/material.dart';
import '../core/theme/civic_horizon_theme.dart';

class DashboardTimeclock extends StatelessWidget {
  const DashboardTimeclock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicHorizonTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildDigitalClock(),
                    const SizedBox(height: 48),
                    _buildStatusBar(),
                    const SizedBox(height: 48),
                    _buildActionButtons(),
                    const SizedBox(height: 48),
                    _buildProgressIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surface.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: CivicHorizonTheme.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const Text(
                'PRISM',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: CivicHorizonTheme.primary,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: CivicHorizonTheme.primaryContainer,
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBGk-Fvgr3zIM0ERXwAtXf_Vk068kgBaBt_9_UtIxdKOUjxSGMqDYibLGYEKLMdJPu2UD-SXz0CLZIfAqNeiJZior64yu35DRS41Uzkdk1jUFvdXvXhLXdbBk6rFhScpUllmSO6bXVud3YiU6DEboHnrsgtfJDMu55yZzjJtYgyPaiAWVQgiXlTLS0CFOyyv-4Pb6Y0PpsAAt9U5Y3KU_LGyVnDibeSKOz7vxYo_EyJKkgsQJboQ4rGn1LP9qzKu48tJ9moToMOmc4'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalClock() {
    return Column(
      children: [
        const Text(
          'STANDARD TIME REGISTRY',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: CivicHorizonTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: const [
            Text(
              '08:30',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: CivicHorizonTheme.primary,
                letterSpacing: -2.0,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'AM',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: CivicHorizonTheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusPill(Icons.location_on, 'GPS: Active'),
        const SizedBox(width: 24),
        _buildStatusPill(Icons.camera_alt, 'Camera: Ready'),
      ],
    );
  }

  Widget _buildStatusPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: CivicHorizonTheme.onTertiaryFixedVariant),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: CivicHorizonTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: CivicHorizonTheme.ghostBorder,
              boxShadow: CivicHorizonTheme.ambientGlow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SHIFT START',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: CivicHorizonTheme.onTertiaryFixedVariant,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CLOCK IN',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: CivicHorizonTheme.tertiaryFixed,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CivicHorizonTheme.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_front,
                    color: CivicHorizonTheme.onTertiaryFixedVariant,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CivicHorizonTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(
                  color: CivicHorizonTheme.error,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'END REGISTRY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CivicHorizonTheme.onSurfaceVariant,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CLOCK OUT',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: CivicHorizonTheme.error,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.stop_circle,
                  color: CivicHorizonTheme.error,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CivicHorizonTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HOURGLASS PROGRESS',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: CivicHorizonTheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Text(
                    '120',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: CivicHorizonTheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '/ 486 Hours',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CivicHorizonTheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'COMPLETED THIS CYCLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: CivicHorizonTheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: 120 / 486,
                  strokeWidth: 8,
                  backgroundColor: CivicHorizonTheme.primaryContainer,
                  color: CivicHorizonTheme.tertiaryFixedDim,
                ),
              ),
              const Text(
                '24%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: CivicHorizonTheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: CivicHorizonTheme.surfaceContainerHigh.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', isActive: true),
              _buildNavItem(Icons.edit_note, 'Journal'),
              _buildNavItem(Icons.analytics, 'Reports'),
              _buildNavItem(Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    final color = isActive ? CivicHorizonTheme.primary : const Color(0xFF94A3B8);
    final bgColor = isActive ? CivicHorizonTheme.primary.withOpacity(0.1) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
