import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import 'dart:developer' as developer; // Added for logging

class ShopScreens extends StatefulWidget {
  const ShopScreens({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreens> {
  final String _mapTilerApiKey = 'lHexwJZXxcXlK7A0DtHo';
  final StreamController<List<Map<String, dynamic>>> _storeStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Timer? _timer;
  int _selectedStoreIndex = 0;
  final double _hardcodedLat = 19.0760;
  final double _hardcodedLon = 72.8777;
  late bool isSmallScreen; // For responsive design

  @override
  void initState() {
    super.initState();
    developer.log('initState called, starting data stream', name: 'ShopScreens');
    _startDataStream();
  }

  @override
  void dispose() {
    developer.log('Disposing ShopScreens, closing StreamController and cancelling timer', name: 'ShopScreens');
    _storeStreamController.close();
    _timer?.cancel();
    super.dispose();
  }

  void _startDataStream() {
    developer.log('Starting data stream', name: 'ShopScreens');
    List<Map<String, dynamic>> initialStores = [
      {
        'name': 'Mahima Medical Store',
        'address': 'Anurag Chowk, Gorakhpur-273001',
        'lat': 26.7606,
        'lon': 83.3732,
        'distance': Geolocator.distanceBetween(_hardcodedLat, _hardcodedLon, 26.7606, 83.3732) / 1000,
        'items': [
          {'name': 'Stayfree Secure Pads', 'price': 189.0, 'tags': ['Sanitary Pads'], 'stock': 50},
          {'name': 'Ibuprofen (Pain Relief)', 'price': 120.0, 'tags': ['Menstrual Relief'], 'stock': 30},
        ],
      },
      {
        'name': 'Priya Women’s Clinic Store',
        'address': 'Powai, Mumbai-100075',
        'lat': 19.1155,
        'lon': 72.9089,
        'distance': Geolocator.distanceBetween(_hardcodedLat, _hardcodedLon, 19.1155, 72.9089) / 1000,
        'items': [
          {'name': 'Sofy Antibacterial Pads', 'price': 250.0, 'tags': ['Sanitary Pads'], 'stock': 25},
          {'name': 'Heat Patch (Cramps)', 'price': 150.0, 'tags': ['Menstrual Relief'], 'stock': 20},
        ],
      },
      {
        'name': 'Gupta Health Hub',
        'address': 'Shubhash Nagar, Kota-324001',
        'lat': 25.2138,
        'lon': 75.8643,
        'distance': Geolocator.distanceBetween(_hardcodedLat, _hardcodedLon, 25.2138, 75.8643) / 1000,
        'items': [
          {'name': 'Stayfree Overnight Pads', 'price': 199.0, 'tags': ['Sanitary Pads'], 'stock': 35},
          {'name': 'Menstrual Cup (Medium)', 'price': 300.0, 'tags': ['Menstrual Products'], 'stock': 15},
        ],
      },
    ];

    initialStores.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    developer.log('Adding initial stores to StreamController: ${initialStores.length} stores', name: 'ShopScreens');
    _storeStreamController.add(initialStores);

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_storeStreamController.isClosed) {
        final updatedStores = List<Map<String, dynamic>>.from(initialStores);
        for (var store in updatedStores) {
          for (var item in store['items']) {
            item['stock'] = (item['stock'] as int) - (1 + (DateTime.now().second % 3));
            if (item['stock'] < 0) item['stock'] = 0;
          }
        }
        developer.log('Updating stores with new stock levels', name: 'ShopScreens');
        _storeStreamController.add(updatedStores);
      }
    });
  }

  Widget _buildNearbyStoresCard(List<Map<String, dynamic>> stores) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby Stores',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.deepPlum,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isSmallScreen ? 90 : 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  final isSelected = index == _selectedStoreIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStoreIndex = index;
                      });
                    },
                    child: Container(
                      width: isSmallScreen ? 180 : 200,
                      margin: const EdgeInsets.only(right: 12.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? AppColors.blushRose : Colors.grey[300]!,
                          ),
                        ),
                        elevation: isSelected ? 4 : 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: isSmallScreen ? 25 : 30,
                                    height: isSmallScreen ? 25 : 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.blushRose,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (store['name'] as String?)?.isNotEmpty == true
                                            ? store['name'][0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: AppColors.deepPlum,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      store['name']?.toString() ?? 'Unknown Store',
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: AppColors.deepPlum,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  '${store['address']?.toString() ?? 'Unknown Address'} (${(store['distance'] as double?)?.toStringAsFixed(1) ?? '0.0'} km)',
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: isSmallScreen ? 9 : 10,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(Map<String, dynamic> selectedStore) {
    final user = Provider.of<User>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: AppColors.pearlWhite,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Items at ${selectedStore['name']?.toString() ?? 'Unknown Store'}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.deepPlum,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (selectedStore['items'] as List?)?.length ?? 0,
              itemBuilder: (context, index) {
                final item = selectedStore['items'][index];
                final itemName = item['name'] as String? ?? 'Unknown Item';
                final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                final itemTags = (item['tags'] as List<dynamic>?)?.cast<String>() ?? [];
                final itemStock = (item['stock'] as int?) ?? 0;
                final cartQuantity = user.cartItems[itemName] ?? 0;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                itemName,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: AppColors.deepPlum,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                              ),
                            ),
                            Text(
                              '${itemPrice.toStringAsFixed(0)} INR',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.deepPlum,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock: $itemStock',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: itemStock > 0 ? Colors.green : Colors.red,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ExpansionTile(
                          title: Text(
                            'Item Detail',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                          ),
                          children: itemTags.isNotEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      '#${itemTags.join(', #')}',
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                    ),
                                  ),
                                ]
                              : [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Text('No tags available'),
                                  ),
                                ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: itemStock > 0
                                  ? () {
                                      user.addToCart(itemName);
                                      setState(() {}); // Trigger UI update
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$itemName added to cart!'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: Icon(Icons.add_shopping_cart, size: isSmallScreen ? 14 : 16),
                              label: Text(
                                'Add to cart',
                                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blushRose,
                                foregroundColor: AppColors.deepPlum,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 12 : 16,
                                  vertical: isSmallScreen ? 6 : 8,
                                ),
                              ),
                            ),
                            if (cartQuantity > 0)
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        user.removeFromCart(itemName);
                                        setState(() {}); // Trigger UI update
                                      },
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      iconSize: isSmallScreen ? 20 : 24,
                                    ),
                                    Flexible(
                                      child: Text(
                                        '$cartQuantity Added',
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: AppColors.deepPlum,
                                              fontSize: isSmallScreen ? 12 : 14,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${(itemPrice * cartQuantity).toStringAsFixed(0)} INR',
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                              color: AppColors.deepPlum,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 12 : 14,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 600; // Compute screen size

    return Scaffold( // Temporarily added for debugging
      appBar: AppBar(
        title: const Text('Shop for Women’s Needs'),
        backgroundColor: AppColors.blushRose,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _storeStreamController.stream,
        initialData: [],
        builder: (context, snapshot) {
          developer.log('StreamBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}', name: 'ShopScreens');
          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('StreamBuilder waiting for data', name: 'ShopScreens');
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            developer.log('No stores available', name: 'ShopScreens');
            return const Center(child: Text('No stores available'));
          }

          final stores = snapshot.data!;
          final selectedStore = stores[_selectedStoreIndex];
          developer.log('Rendering UI with ${stores.length} stores, selected store: ${selectedStore['name']}', name: 'ShopScreens');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNearbyStoresCard(stores),
                const SizedBox(height: 24),
                _buildItemsCard(selectedStore),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}