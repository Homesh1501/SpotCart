import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/menu_item_model.dart';
import '../../auth/controllers/auth_controller.dart';

final menuControllerProvider = StateNotifierProvider<MenuController, AsyncValue<void>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return MenuController(isDemo: isDemo);
});

final vendorMenuItemsProvider = StreamProvider.family<List<MenuItemModel>, String>((ref, vendorId) {
  final isDemo = ref.watch(isDemoModeProvider);
  if (isDemo) {
    Stream<List<MenuItemModel>> getDemoStream() async* {
      yield MenuController._mockItems;
      await for (final items in MenuController._mockStreamController.stream) {
        yield items;
      }
    }
    return getDemoStream().map(
      (items) => items.where((item) => item.vendorId == vendorId).toList(),
    );
  }

  return FirebaseFirestore.instance
      .collection('menu_items')
      .where('vendorId', isEqualTo: vendorId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
          .toList());
});

class MenuController extends StateNotifier<AsyncValue<void>> {
  final bool isDemo;
  MenuController({this.isDemo = false}) : super(const AsyncData(null));

  late final FirebaseFirestore? _firestore = isDemo ? null : FirebaseFirestore.instance;
  late final FirebaseStorage? _storage = isDemo ? null : FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Global static mock database for demo mode
  static final List<MenuItemModel> _mockItems = [
    MenuItemModel(
      id: 'mock_item_1',
      name: 'Caramelized Onion Burger',
      price: 180.00,
      description: 'Juicy grass-fed beef, slow caramelized onions, brown butter glaze, and cheddar.',
      imageUrl: '',
      isTodaySpecial: true,
      vendorId: 'mock_user_id', // Owned by the mock vendor
    ),
    MenuItemModel(
      id: 'mock_item_2',
      name: 'Earthy Sweet Potato Fries',
      price: 120.00,
      description: 'Crispy hand-cut sweet potato fries with brown sugar dust and spicy cream.',
      imageUrl: '',
      isTodaySpecial: false,
      vendorId: 'mock_user_id',
    ),
    MenuItemModel(
      id: 'mock_item_3',
      name: 'Spicy Street Fish Tacos',
      price: 160.00,
      description: 'Crispy cod fillet, shredded cabbage, citrus cilantro cream, orange zest sauce.',
      imageUrl: '',
      isTodaySpecial: true,
      vendorId: 'mock_vendor_2', // Owned by another vendor on the map
    ),
    MenuItemModel(
      id: 'mock_item_4',
      name: 'Avocado Cream Dip',
      price: 110.00,
      description: 'Smooth avocado dip with fresh cilantro and lime.',
      imageUrl: '',
      isTodaySpecial: false,
      vendorId: 'mock_vendor_2',
    ),
  ];

  static final StreamController<List<MenuItemModel>> _mockStreamController = 
      StreamController<List<MenuItemModel>>.broadcast()..add(_mockItems);

  static void refreshMockStream() {
    _mockStreamController.add(List.from(_mockItems));
  }

  Future<void> addMenuItem({
    required String name,
    required double price,
    required String vendorId,
    String? description,
    File? imageFile,
    bool isTodaySpecial = false,
    String category = 'Meals',
  }) async {
    state = const AsyncLoading();
    try {
      final itemId = _uuid.v4();
      String? imageUrl;

      if (isDemo) {
        await Future.delayed(const Duration(milliseconds: 500));
        imageUrl = imageFile != null ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=150' : '';
        final newItem = MenuItemModel(
          id: itemId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          isTodaySpecial: isTodaySpecial,
          vendorId: vendorId,
          description: description,
          category: category,
          isSoldOut: false,
        );
        _mockItems.add(newItem);
        refreshMockStream();
        state = const AsyncData(null);
        return;
      }

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, itemId);
      }

      final newItem = MenuItemModel(
        id: itemId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        isTodaySpecial: isTodaySpecial,
        vendorId: vendorId,
        description: description,
        category: category,
        isSoldOut: false,
      );

      await _firestore!.collection('menu_items').doc(itemId).set(newItem.toMap());
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateMenuItem({
    required MenuItemModel item,
    File? imageFile,
  }) async {
    state = const AsyncLoading();
    try {
      String? imageUrl = item.imageUrl;

      if (isDemo) {
        await Future.delayed(const Duration(milliseconds: 500));
        imageUrl = imageFile != null ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=150' : item.imageUrl;
        final index = _mockItems.indexWhere((element) => element.id == item.id);
        if (index != -1) {
          _mockItems[index] = item.copyWith(imageUrl: imageUrl);
          refreshMockStream();
        }
        state = const AsyncData(null);
        return;
      }

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, item.id);
      }

      final updatedItem = item.copyWith(imageUrl: imageUrl);
      await _firestore!.collection('menu_items').doc(item.id).update(updatedItem.toMap());
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> toggleSpecial(String itemId, bool isSpecial) async {
    try {
      if (isDemo) {
        final index = _mockItems.indexWhere((element) => element.id == itemId);
        if (index != -1) {
          _mockItems[index] = _mockItems[index].copyWith(isTodaySpecial: isSpecial);
          refreshMockStream();
        }
        return;
      }
      await _firestore!.collection('menu_items').doc(itemId).update({
        'isTodaySpecial': isSpecial,
      });
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> toggleSoldOut(String itemId, bool isSoldOut) async {
    try {
      if (isDemo) {
        final index = _mockItems.indexWhere((element) => element.id == itemId);
        if (index != -1) {
          _mockItems[index] = _mockItems[index].copyWith(isSoldOut: isSoldOut);
          refreshMockStream();
        }
        return;
      }
      await _firestore!.collection('menu_items').doc(itemId).update({
        'isSoldOut': isSoldOut,
      });
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    state = const AsyncLoading();
    try {
      if (isDemo) {
        await Future.delayed(const Duration(milliseconds: 500));
        _mockItems.removeWhere((element) => element.id == itemId);
        refreshMockStream();
        state = const AsyncData(null);
        return;
      }

      final doc = await _firestore!.collection('menu_items').doc(itemId).get();
      if (doc.exists) {
        final data = doc.data();
        final imageUrl = data?['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            await _storage!.refFromURL(imageUrl).delete();
          } catch (storageErr) {
            // Ignore storage deletion errors and continue deleting document
          }
        }
      }
      
      await _firestore!.collection('menu_items').doc(itemId).delete();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<String> _uploadImage(File file, String itemId) async {
    final ref = _storage!.ref().child('menu_images').child('$itemId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
