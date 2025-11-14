import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/views/roomScreens/room_selection_screen.dart';
import 'package:inventory_tracker/views/locationScreens/add_location_screen.dart';
import 'package:inventory_tracker/views/roomScreens/room_creation_screen.dart';

class FloatingNavbar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<FloatingNavbar> createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _closeFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _fabAnimationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dim background when expanded
        if (_isFabExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFab,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // Navbar container
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, context, Icons.home_filled, 'Home'),
                  const SizedBox(width: 56),
                  _buildNavItem(
                    1,
                    context,
                    Icons.location_on,
                    'Locations',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Action Button + options
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isFabExpanded) ...[
                _buildAddOption(
                  'Add Location',
                  Icons.location_on,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLocationScreen(),
                      ),
                    ).then((_) => _closeFab());
                  },
                ),
                const SizedBox(height: 12),
                _buildAddOption(
                  'Add Room',
                  Icons.meeting_room,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomCreationScreen(),
                      ),
                    ).then((_) => _closeFab());
                  },
                ),
                const SizedBox(height: 12),
                _buildAddOption('Add Container', Icons.inventory_2, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoomSelectionScreen(),
                    ),
                  ).then((_) => _closeFab());
                }),
                const SizedBox(height: 12),
                _buildAddOption('Add Item', Icons.add_box, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RoomSelectionScreen(isAddItemScreen: true),
                    ),
                  ).then((_) => _closeFab());
                }),
                const SizedBox(height: 16),
              ],
              FloatingActionButton(
                onPressed: _toggleFab,
                backgroundColor: AppColors.primary,
                elevation: _isFabExpanded ? 8 : 4,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isFabExpanded ? 0.125 : 0,
                  child: Icon(
                    _isFabExpanded ? Icons.close : Icons.add,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddOption(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
          Future.delayed(const Duration(milliseconds: 150), _closeFab);
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    BuildContext context,
    IconData icon,
    String label,
  ) {
    final isSelected = widget.selectedIndex == index;
    return InkWell(
      onTap: () {
        widget.onTabSelected(index);
        _closeFab();
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}