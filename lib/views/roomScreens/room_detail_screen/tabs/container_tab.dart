import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/room_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/header_row.dart';

class ContainersTab extends StatelessWidget {
  final List<dynamic> containers;
  final Room room;
  final VoidCallback onAddPressed;
  final void Function(BuildContext, dynamic) onTap;
  final void Function(BuildContext, dynamic, String, bool) onOptions;

  const ContainersTab({
    required this.containers,
    required this.room,
    required this.onAddPressed,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          HeaderRow(title: 'Containers', onAddPressed: onAddPressed),
          const SizedBox(height: 12),
          if (containers.isEmpty)
            const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No containers added yet',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: containers.length,
              itemBuilder: (context, i) {
                final container = containers[i];
                final containerName = container is String
                    ? container
                    : (container.name ?? 'Unnamed');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => onTap(context, container),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  containerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (container is! String) ...[
                                  if (container.description?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      container.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  if (container.brand?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      container.brand!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary.withOpacity(
                                          0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                onOptions(context, container, room.id, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
