import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/room_model.dart';
import '../../../viewmodels/inventory_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/header_row.dart';

class ContainersTab extends StatefulWidget {
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
  State<ContainersTab> createState() => _ContainersTabState();
}

class _ContainersTabState extends State<ContainersTab> {
  final Set<String> _expandedContainers = {};

  void _toggleContainer(String containerId) {
    setState(() {
      if (_expandedContainers.contains(containerId)) {
        _expandedContainers.remove(containerId);
      } else {
        _expandedContainers.add(containerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          HeaderRow(title: 'Containers', onAddPressed: widget.onAddPressed),
          const SizedBox(height: 12),
          if (widget.containers.isEmpty)
            const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No containers added yet',
            )
          else
            Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.containers.length,
                  itemBuilder: (context, i) {
                    final container = widget.containers[i];
                    final containerName = container is String
                        ? container
                        : (container.name ?? 'Unnamed');
                    final containerId = container is String ? null : container.id;

                    // Get items in this container
                    final containerItems = containerId != null
                        ? inventoryProvider.getContainerItems(
                            widget.room.id,
                            containerId,
                          )
                        : <dynamic>[];

                    final isExpanded = containerId != null &&
                        _expandedContainers.contains(containerId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Container Header
                          InkWell(
                            onTap: () => widget.onTap(context, container),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: colors.primary,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: colors.textPrimary,
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
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                          if (container.brand?.isNotEmpty ??
                                              false) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              container.brand!,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colors.primary.withOpacity(
                                                  0.8,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                        // Item count indicator
                                        if (containerItems.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 14,
                                                color: colors.primary.withOpacity(0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${containerItems.length} item${containerItems.length == 1 ? '' : 's'}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colors.primary.withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Expand/Collapse button (only if container has items)
                                  if (containerItems.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: colors.primary,
                                      ),
                                      onPressed: () => _toggleContainer(containerId!),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: colors.textSecondary,
                                    ),
                                    onPressed: () => widget.onOptions(
                                      context,
                                      container,
                                      widget.room.id,
                                      false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Items List
                          if (isExpanded && containerItems.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: colors.background.withOpacity(.5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.surface,
                                    blurRadius: 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 56),
                                        Text(
                                          'Items in this container',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colors.textSecondary.withOpacity(0.8),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: containerItems.length,
                                    itemBuilder: (context, itemIndex) {
                                      final item = containerItems[itemIndex];
                                      final itemName = item.name ?? 'Unnamed Item';

                                      return InkWell(
                                        onTap: () => widget.onTap(context, item),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 12),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: colors.primary.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.shopping_bag_outlined,
                                                  color: colors.primary.withOpacity(0.7),
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            itemName,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 14,
                                                              color: colors.textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        if (item.quantity != null &&
                                                            item.quantity > 1)
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: colors.primary.withOpacity(0.15),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Text(
                                                              'Qty: ${item.quantity}',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: colors.primary,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    if (item.brand?.isNotEmpty ?? false) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        item.brand!,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: colors.textSecondary.withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: colors.textSecondary,
                                                  size: 18,
                                                ),
                                                onPressed: () => widget.onOptions(
                                                  context,
                                                  item,
                                                  widget.room.id,
                                                  true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../models/room_model.dart';
// import '../../../../viewmodels/inventory_provider.dart';
// import '../widgets/empty_state.dart';
// import '../widgets/header_row.dart';

// class ContainersTab extends StatelessWidget {
//   final List<dynamic> containers;
//   final Room room;
//   final VoidCallback onAddPressed;
//   final void Function(BuildContext, dynamic) onTap;
//   final void Function(BuildContext, dynamic, String, bool) onOptions;

//   const ContainersTab({
//     required this.containers,
//     required this.room,
//     required this.onAddPressed,
//     required this.onTap,
//     required this.onOptions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         children: [
//           HeaderRow(title: 'Containers', onAddPressed: onAddPressed),
//           const SizedBox(height: 12),
//           if (containers.isEmpty)
//             const EmptyState(
//               icon: Icons.inventory_2_outlined,
//               title: 'No containers added yet',
//             )
//           else
//             Consumer<InventoryProvider>(
//               builder: (context, inventoryProvider, _) {
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: containers.length,
//                   itemBuilder: (context, i) {
//                     final container = containers[i];
//                     final containerName = container is String
//                         ? container
//                         : (container.name ?? 'Unnamed');
//                     final containerId = container is String ? null : container.id;

//                     // Get items count in this container
//                     final itemCount = containerId != null
//                         ? inventoryProvider.getContainerItemCount(
//                       room.id,
//                       containerId,
//                     )
//                         : 0;

//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       color: AppColors.surface,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: InkWell(
//                         onTap: () => onTap(context, container),
//                         borderRadius: BorderRadius.circular(12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             children: [
//                               Stack(
//                                 children: [
//                                   Container(
//                                     width: 44,
//                                     height: 44,
//                                     decoration: BoxDecoration(
//                                       color: colors.primary.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Icon(
//                                       Icons.inventory_2_outlined,
//                                       color: colors.primary,
//                                       size: 22,
//                                     ),
//                                   ),
//                                   // Item count badge
//                                   if (itemCount > 0)
//                                     Positioned(
//                                       right: -2,
//                                       top: -2,
//                                       child: Container(
//                                         padding: const EdgeInsets.all(4),
//                                         decoration: BoxDecoration(
//                                           color: colors.primary,
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: colors.surface,
//                                             width: 2,
//                                           ),
//                                         ),
//                                         constraints: const BoxConstraints(
//                                           minWidth: 20,
//                                           minHeight: 20,
//                                         ),
//                                         child: Text(
//                                           '$itemCount',
//                                           style: const TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       containerName,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                         color: AppColors.textPrimary,
//                                       ),
//                                     ),
//                                     if (container is! String) ...[
//                                       if (container.description?.isNotEmpty ??
//                                           false) ...[
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           container.description!,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: colors.textSecondary,
//                                           ),
//                                         ),
//                                       ],
//                                       if (container.brand?.isNotEmpty ?? false) ...[
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           container.brand!,
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             color: AppColors.primary.withOpacity(0.8),
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ],
//                                     ],
//                                     // Item count text
//                                     if (itemCount > 0) ...[
//                                       const SizedBox(height: 6),
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.shopping_bag_outlined,
//                                             size: 14,
//                                             color: AppColors.primary.withOpacity(0.7),
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             '$itemCount item${itemCount == 1 ? '' : 's'} inside',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: AppColors.primary.withOpacity(0.9),
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.more_vert,
//                                   color: AppColors.textSecondary,
//                                 ),
//                                 onPressed: () =>
//                                     onOptions(context, container, room.id, false),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }










// // import 'package:flutter/material.dart';
// // import '../../../../core/theme/app_colors.dart';
// // import '../../../../models/room_model.dart';
// // import '../widgets/empty_state.dart';
// // import '../widgets/header_row.dart';
// //
// // class ContainersTab extends StatelessWidget {
// //   final List<dynamic> containers;
// //   final Room room;
// //   final VoidCallback onAddPressed;
// //   final void Function(BuildContext, dynamic) onTap;
// //   final void Function(BuildContext, dynamic, String, bool) onOptions;
// //
// //   const ContainersTab({
// //     required this.containers,
// //     required this.room,
// //     required this.onAddPressed,
// //     required this.onTap,
// //     required this.onOptions,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       child: Column(
// //         children: [
// //           HeaderRow(title: 'Containers', onAddPressed: onAddPressed),
// //           const SizedBox(height: 12),
// //           if (containers.isEmpty)
// //             const EmptyState(
// //               icon: Icons.inventory_2_outlined,
// //               title: 'No containers added yet',
// //             )
// //           else
// //             ListView.builder(
// //               shrinkWrap: true,
// //               physics: const NeverScrollableScrollPhysics(),
// //               itemCount: containers.length,
// //               itemBuilder: (context, i) {
// //                 final container = containers[i];
// //                 final containerName = container is String
// //                     ? container
// //                     : (container.name ?? 'Unnamed');
// //
// //                 return Card(
// //                   margin: const EdgeInsets.only(bottom: 8),
// //                   color: AppColors.surface,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: InkWell(
// //                     onTap: () => onTap(context, container),
// //                     borderRadius: BorderRadius.circular(12),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(12),
// //                       child: Row(
// //                         children: [
// //                           Container(
// //                             width: 44,
// //                             height: 44,
// //                             decoration: BoxDecoration(
// //                               color: AppColors.primary.withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                             child: const Icon(
// //                               Icons.inventory_2_outlined,
// //                               color: AppColors.primary,
// //                               size: 22,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   containerName,
// //                                   style: const TextStyle(
// //                                     fontWeight: FontWeight.w600,
// //                                     fontSize: 15,
// //                                     color: AppColors.textPrimary,
// //                                   ),
// //                                 ),
// //                                 if (container is! String) ...[
// //                                   if (container.description?.isNotEmpty ??
// //                                       false) ...[
// //                                     const SizedBox(height: 4),
// //                                     Text(
// //                                       container.description!,
// //                                       maxLines: 1,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       style: const TextStyle(
// //                                         fontSize: 12,
// //                                         color: colors.textSecondary,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                   if (container.brand?.isNotEmpty ?? false) ...[
// //                                     const SizedBox(height: 2),
// //                                     Text(
// //                                       container.brand!,
// //                                       style: TextStyle(
// //                                         fontSize: 11,
// //                                         color: AppColors.primary.withOpacity(
// //                                           0.8,
// //                                         ),
// //                                         fontWeight: FontWeight.w500,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ],
// //                               ],
// //                             ),
// //                           ),
// //                           IconButton(
// //                             icon: const Icon(
// //                               Icons.more_vert,
// //                               color: AppColors.textSecondary,
// //                             ),
// //                             onPressed: () =>
// //                                 onOptions(context, container, room.id, false),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
