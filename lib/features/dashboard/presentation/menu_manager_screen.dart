import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/menu_controller.dart';
import '../../../models/menu_item_model.dart';
import '../../../theme.dart';

class MenuManagerScreen extends ConsumerStatefulWidget {
  const MenuManagerScreen({super.key});

  @override
  ConsumerState<MenuManagerScreen> createState() => _MenuManagerScreenState();
}

class _MenuManagerScreenState extends ConsumerState<MenuManagerScreen> {
  String _activeCategoryFilter = 'All';

  void _showAddEditDialog(BuildContext context, String vendorId, [MenuItemModel? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditMenuForm(vendorId: vendorId, item: item),
    );
  }

  void _showDeleteConfirm(BuildContext context, MenuItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete "${item.name}" from your menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(menuControllerProvider.notifier).deleteMenuItem(item.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final vendorId = authState.user?.id ?? '';
    final menuItemsAsync = ref.watch(vendorMenuItemsProvider(vendorId));

    ref.listen(menuControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operation failed: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, vendorId),
        icon: const Icon(Icons.add),
        label: const Text('Add Dish'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Chips for Categories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Meals', 'Snacks', 'Drinks', 'Specials'].map((cat) {
                  final isSelected = _activeCategoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _activeCategoryFilter = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: menuItemsAsync.when(
              data: (items) {
                // Apply Category Filter
                final filteredItems = items.where((item) {
                  if (_activeCategoryFilter == 'All') return true;
                  if (_activeCategoryFilter == 'Specials') return item.isTodaySpecial;
                  return item.category == _activeCategoryFilter;
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _activeCategoryFilter == 'All' 
                                ? 'Your menu is empty' 
                                : 'No items in $_activeCategoryFilter',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _activeCategoryFilter == 'All'
                                ? 'Tap the "Add Dish" button below to list your first food item.'
                                : 'Try adding a dish to this category or checking another one.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 88),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: item.isSoldOut 
                          ? (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade100)
                          : Theme.of(context).cardTheme.color,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Food Image Preview
                            Opacity(
                              opacity: item.isSoldOut ? 0.4 : 1.0,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.fastfood, color: Colors.orange.shade800, size: 30),
                                        ),
                                      )
                                    : Icon(Icons.fastfood, color: Colors.orange.shade800, size: 30),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: item.isSoldOut ? TextDecoration.lineThrough : null,
                                            color: item.isSoldOut ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      if (item.isSoldOut)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.dangerRed.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'SOLD OUT',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.dangerRed,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (item.description != null && item.description!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: item.isSoldOut ? Colors.grey : AppTheme.primaryOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Switch Row
                                  Row(
                                    children: [
                                      // Sold out Switch
                                      const Text('Sold out: ', style: TextStyle(fontSize: 11)),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: item.isSoldOut,
                                          onChanged: (val) {
                                            ref.read(menuControllerProvider.notifier).toggleSoldOut(item.id, val);
                                          },
                                        ),
                                      ),
                                      const Spacer(),
                                      // Special Switch
                                      const Text('Special: ', style: TextStyle(fontSize: 11)),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: item.isTodaySpecial,
                                          onChanged: (val) {
                                            ref.read(menuControllerProvider.notifier).toggleSpecial(item.id, val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showAddEditDialog(context, vendorId, item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _showDeleteConfirm(context, item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading menu: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEditMenuForm extends ConsumerStatefulWidget {
  final String vendorId;
  final MenuItemModel? item;

  const _AddEditMenuForm({required this.vendorId, this.item});

  @override
  ConsumerState<_AddEditMenuForm> createState() => _AddEditMenuFormState();
}

class _AddEditMenuFormState extends ConsumerState<_AddEditMenuForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  bool _isTodaySpecial = false;
  String _selectedCategory = 'Meals';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _isTodaySpecial = widget.item?.isTodaySpecial ?? false;
    _selectedCategory = widget.item?.category ?? 'Meals';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final desc = _descController.text.trim();

      if (widget.item == null) {
        // Add
        await ref.read(menuControllerProvider.notifier).addMenuItem(
              name: name,
              price: price,
              vendorId: widget.vendorId,
              description: desc,
              imageFile: _imageFile,
              isTodaySpecial: _isTodaySpecial,
              category: _selectedCategory,
            );
      } else {
        // Edit
        final updated = widget.item!.copyWith(
          name: name,
          price: price,
          description: desc,
          isTodaySpecial: _isTodaySpecial,
          category: _selectedCategory,
        );
        await ref.read(menuControllerProvider.notifier).updateMenuItem(
              item: updated,
              imageFile: _imageFile,
            );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuControllerProvider);
    final isEditing = widget.item != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Food Item' : 'Add New Food Item',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 20),
              // Image Picker Selector
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : (widget.item?.imageUrl != null && widget.item!.imageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(widget.item!.imageUrl!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600, size: 36),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Upload Photo',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dish Name',
                  hintText: 'e.g. Crispy Fish Tacos',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter dish name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  hintText: 'e.g. 8.50',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter price';
                  if (double.tryParse(val) == null) return 'Please enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Spicy fish tacos with fresh avocado sauce...',
                ),
              ),
               const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Meals', 'Snacks', 'Drinks', 'Specials'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Feature as Today\'s Special?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isTodaySpecial,
                    onChanged: (val) {
                      setState(() {
                        _isTodaySpecial = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: menuState is AsyncLoading ? null : _submit,
                child: menuState is AsyncLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
