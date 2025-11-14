import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class CustomQuantityField extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;
  final String label;
  final String hint;

  const CustomQuantityField({
    super.key,
    this.initialValue = 1,
    required this.onChanged,
    this.label = 'Quantity',
    this.hint = 'Enter quantity',
  });

  @override
  _CustomQuantityFieldState createState() => _CustomQuantityFieldState();
}

class _CustomQuantityFieldState extends State<CustomQuantityField> {
  late int _quantity;
  late TextEditingController _controller; // Add controller

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
    _controller = TextEditingController(text: _quantity.toString()); // Initialize controller
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  void _increment() {
    setState(() {
      _quantity++;
      _controller.text = _quantity.toString(); // Update controller
    });
    widget.onChanged(_quantity);
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString(); // Update controller
      });
      widget.onChanged(_quantity);
    }
  }

  void _onQuantityChanged(String value) {
    if (value.isNotEmpty) {
      final newQuantity = int.tryParse(value) ?? 0;
      if (newQuantity >= 0) {
        setState(() {
          _quantity = newQuantity;
        });
        widget.onChanged(_quantity);
      }
    } else {
      setState(() {
        _quantity = 0;
      });
      widget.onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Minus Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.remove, color: AppColors.primary),
                onPressed: _decrement,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            
            // Quantity Field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextFormField(
                  controller: _controller, // Use controller instead of initialValue
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: _onQuantityChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Quantity is required';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Quantity must be a positive number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            
            // Plus Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: _increment,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ],
        ),
      ],
    );
  }
}