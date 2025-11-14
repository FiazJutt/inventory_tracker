import 'package:flutter/material.dart';
import 'package:inventory_tracker/models/container_model.dart';
import 'package:provider/provider.dart';
import 'package:inventory_tracker/viewmodels/inventory_provider.dart';
import 'package:inventory_tracker/models/room_model.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/core/widgets/form_widgets/form_widgets.dart';
import 'widgets/location_info_card.dart';

class ContainerItemFormPage extends StatefulWidget {
  final Room room;
  final ContainerModel? container; // NEW: optional container
  final bool isAddItemScreen;
  final bool fromRoomDetailScreen;

  const ContainerItemFormPage({
    super.key,
    required this.room,
    this.container, // NEW
    this.isAddItemScreen = false,
    this.fromRoomDetailScreen = false,
  });

  @override
  _ContainerItemFormPageState createState() => _ContainerItemFormPageState();
}

class _ContainerItemFormPageState extends State<ContainerItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _containerNameController =
      TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _retailerController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _searchMetadataController =
      TextEditingController();

  DateTime? _purchaseDate;
  DateTime? _expirationDate;
  String? _currentCondition;
  int _quantity = 1;
  bool _isLoading = false;

  final List<String> _conditions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Fair',
    'Refurbished',
  ];

  @override
  void dispose() {
    _containerNameController.dispose();
    _serialNumberController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _weightController.dispose();
    _retailerController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _searchMetadataController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final colors = context.appColors;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate
          ? (_purchaseDate ?? DateTime.now())
          : (_expirationDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.primary,
              onPrimary: Colors.black,
              surface: colors.surface,
              onSurface: colors.textPrimary,
            ),
            dialogBackgroundColor: colors.background,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }


  Future<void> _addContainer() async {
    final colors = context.appColors;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final containerName = _containerNameController.text.trim();
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

      if (widget.isAddItemScreen) {
        inventoryProvider.addItem(
          widget.room.id,
          containerName,
          containerId: widget.container?.id, // NEW: pass container ID
          quantity: _quantity,
          serialNumber: _serialNumberController.text.trim(),
          notes: _notesController.text.trim(),
          description: _descriptionController.text.trim(),
          purchasePrice: _purchasePriceController.text.trim().isNotEmpty
              ? double.tryParse(_purchasePriceController.text.trim())
              : null,
          purchaseDate: _purchaseDate,
          currentValue: _currentValueController.text.trim().isNotEmpty
              ? double.tryParse(_currentValueController.text.trim())
              : null,
          currentCondition: _currentCondition,
          expirationDate: _expirationDate,
          weight: _weightController.text.trim().isNotEmpty
              ? double.tryParse(_weightController.text.trim())
              : null,
          retailer: _retailerController.text.trim(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          searchMetadata: _searchMetadataController.text.trim(),
        );
      } else {
        inventoryProvider.addContainer(
          widget.room.id,
          containerName,
          serialNumber: _serialNumberController.text.trim(),
          notes: _notesController.text.trim(),
          description: _descriptionController.text.trim(),
          purchasePrice: _purchasePriceController.text.trim().isNotEmpty
              ? double.tryParse(_purchasePriceController.text.trim())
              : null,
          purchaseDate: _purchaseDate,
          currentValue: _currentValueController.text.trim().isNotEmpty
              ? double.tryParse(_currentValueController.text.trim())
              : null,
          currentCondition: _currentCondition,
          expirationDate: _expirationDate,
          weight: _weightController.text.trim().isNotEmpty
              ? double.tryParse(_weightController.text.trim())
              : null,
          retailer: _retailerController.text.trim(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          searchMetadata: _searchMetadataController.text.trim(),
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (widget.fromRoomDetailScreen) {
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }

      final locationText = widget.container != null
          ? 'container "${widget.container!.name}" in ${widget.room.name}'
          : widget.room.name;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAddItemScreen
                ? 'Item "$containerName" added to $locationText'
                : 'Container "$containerName" added to ${widget.room.name}',
          ),
          backgroundColor: colors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
      return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isAddItemScreen ? 'Add Item' : 'Add Container',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationInfoCard(
                      room: widget.room,
                      container: widget.container,
                      isAddItemScreen: widget.isAddItemScreen,
                    ),
                    const SizedBox(height: 32),

                    // Rest of the form (unchanged)
                    SectionHeader(title: 'Basic Information'),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _containerNameController,
                      label: widget.isAddItemScreen
                          ? 'Item Name'
                          : 'Container Name',
                      hint: widget.isAddItemScreen
                          ? 'e.g., Laptop, Phone, Headphones'
                          : 'e.g., Drawer, Cabinet, Box',
                      icon: Icons.inventory_2_outlined,
                      required: true,
                    ),

                   // Show quantity field only when opened from Add Item screen
                    if (widget.isAddItemScreen) ...[
                      const SizedBox(height: 16),
                      CustomQuantityField(
                        initialValue: _quantity,
                        onChanged: (value) {
                          setState(() {
                            _quantity = value;
                          });
                        },
                        label: 'Quantity',
                        hint: 'Enter quantity',
                      ),
                    ],

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _brandController,
                      label: 'Brand / Name',
                      hint: 'e.g., IKEA, Samsung',
                      icon: Icons.business_outlined,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _modelController,
                      label: 'Model',
                      hint: 'e.g., Model XYZ-123',
                      icon: Icons.label_outline,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _serialNumberController,
                      label: 'Serial Number',
                      hint: 'Enter serial number',
                      icon: Icons.qr_code,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Brief description of the container',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),

                    // Purchase Information Section
                    SectionHeader(title: 'Purchase Information'),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _purchasePriceController,
                      label: 'Purchase Price',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: '\$',
                    ),

                    const SizedBox(height: 16),

                    CustomDateField(
                      label: 'Purchase Date',
                      date: _purchaseDate,
                      onTap: () => _selectDate(context, true),
                      icon: Icons.calendar_today,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _retailerController,
                      label: 'Retailer',
                      hint: 'Where was it purchased?',
                      icon: Icons.store_outlined,
                    ),

                    const SizedBox(height: 32),

                    // Current Information Section
                    SectionHeader(title: 'Current Information'),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _currentValueController,
                      label: 'Current Value',
                      hint: '0.00',
                      icon: Icons.trending_up,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: '\$',
                    ),

                    const SizedBox(height: 16),

                    CustomDropdownField<String>(
                      label: 'Current Condition',
                      value: _currentCondition,
                      items: _conditions,
                      onChanged: (value) {
                        setState(() {
                          _currentCondition = value;
                        });
                      },
                      icon: Icons.star_outline,
                      hint: 'Select condition',
                    ),

                    const SizedBox(height: 16),

                    CustomDateField(
                      label: 'Expiration Date',
                      date: _expirationDate,
                      onTap: () => _selectDate(context, false),
                      icon: Icons.event_busy,
                    ),

                    const SizedBox(height: 32),

                    // Additional Information Section
                    SectionHeader(title: 'Additional Information'),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: '0.0',
                      icon: Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffixText: 'kg',
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Any additional notes',
                      icon: Icons.note_outlined,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _searchMetadataController,
                      label: 'Search Metadata',
                      hint: 'Keywords for searching',
                      icon: Icons.search,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Button (unchanged)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: widget.isAddItemScreen ? 'Add Item' : 'Add Container',
                onPressed: _addContainer,
                icon: Icons.add,
                isFullWidth: true,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}