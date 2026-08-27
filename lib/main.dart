import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MarketplaceFoodApp());
}

class MarketplaceFoodApp extends StatelessWidget {
  const MarketplaceFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Multi-Lojas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEA1D2C), // Vermelho iFood
          primary: const Color(0xFFEA1D2C),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      home: const CustomerMainTabsScreen(),
    );
  }
}

// ============================================================================
// WIDGET INTELIGENTE DE IMAGEM (SUPORTA INTERNET E GALERIA LOCAL)
// ============================================================================
class SmartImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  const SmartImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: Icon(fallbackIcon, size: 30, color: Colors.grey),
      );
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(fallbackIcon, size: 30, color: Colors.grey),
        ),
      );
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(fallbackIcon, size: 30, color: Colors.grey),
    );
  }
}

// ============================================================================
// MODELOS DE DADOS
// ============================================================================
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;

  CategoryItem({required this.id, required this.name, required this.icon});
}

class ProductItem {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String imagePath;

  ProductItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });
}

class Store {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String logoPath;
  final String bannerPath;
  bool isOpen;
  final List<ProductItem> products;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.logoPath,
    required this.bannerPath,
    this.isOpen = true,
    required this.products,
  });
}

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class PlatformOrder {
  final String id;
  final String storeId;
  final String storeName;
  final String customerName;
  final String phone;
  final String address;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String? changeFor;
  final DateTime createdAt;
  String status; // 'Pendente', 'Em Preparo', 'Em Rota', 'Entregue'

  PlatformOrder({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    this.changeFor,
    required this.createdAt,
    this.status = 'Pendente',
  });
}

// ============================================================================
// SERVIÇO GLOBAL DE ESTADO (MEMÓRIA)
// ============================================================================
class MarketplaceService {
  static final MarketplaceService instance = MarketplaceService._internal();
  MarketplaceService._internal();

  final List<CategoryItem> categories = [
    CategoryItem(id: 'all', name: 'Tudo', icon: Icons.grid_view_rounded),
    CategoryItem(id: 'burger', name: 'Lanches', icon: Icons.lunch_dining_rounded),
    CategoryItem(id: 'pizza', name: 'Pizzas', icon: Icons.local_pizza_rounded),
    CategoryItem(id: 'drinks', name: 'Bebidas', icon: Icons.sports_bar_rounded),
    CategoryItem(id: 'dessert', name: 'Doces', icon: Icons.cake_rounded),
    CategoryItem(id: 'brazilian', name: 'Marmitas', icon: Icons.restaurant_rounded),
    CategoryItem(id: 'pharmacy', name: 'Farmácia', icon: Icons.local_pharmacy_rounded),
  ];

  final ValueNotifier<List<Store>> storesNotifier = ValueNotifier([
    Store(
      id: '1',
      name: 'Burger & Cia Gourmet',
      category: 'Lanches',
      rating: 4.8,
      deliveryTime: '30-45 min',
      deliveryFee: 5.99,
      logoPath: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=300',
      bannerPath: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=800',
      products: [
        ProductItem(
          id: 'p1',
          storeId: '1',
          name: 'Smash Bacon Duplo',
          description: '2 burgers de 90g, muito queijo cheddar e fatias de bacon crocante.',
          price: 28.90,
          imagePath: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        ),
        ProductItem(
          id: 'p2',
          storeId: '1',
          name: 'Batata Rústica c/ Cheddar',
          description: 'Porção individual com molho especial artesanal da casa.',
          price: 16.00,
          imagePath: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
        ),
      ],
    ),
    Store(
      id: '2',
      name: 'Adega Express Delivery',
      category: 'Bebidas',
      rating: 4.9,
      deliveryTime: '20-35 min',
      deliveryFee: 4.00,
      logoPath: 'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?w=300',
      bannerPath: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800',
      products: [
        ProductItem(
          id: 'p3',
          storeId: '2',
          name: 'Combo Whisky + 4 Energéticos',
          description: 'Garrafa 1L + 4 latas energéticos trincando de geladas.',
          price: 119.90,
          imagePath: 'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?w=400',
        ),
        ProductItem(
          id: 'p4',
          storeId: '2',
          name: 'Pack Cerveja 350ml (12 un)',
          description: 'Pack com 12 unidades super geladas para entrega imediata.',
          price: 48.00,
          imagePath: 'https://images.unsplash.com/photo-1608270199144-8463e2609072?w=400',
        ),
      ],
    ),
    Store(
      id: '3',
      name: 'Pizzaria Bella Fornada',
      category: 'Pizzas',
      rating: 4.7,
      deliveryTime: '40-55 min',
      deliveryFee: 7.00,
      logoPath: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300',
      bannerPath: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
      products: [
        ProductItem(
          id: 'p5',
          storeId: '3',
          name: 'Pizza Calabresa Especial',
          description: 'Molho artesanal, mussarela, calabresa fatiada e cebola.',
          price: 52.00,
          imagePath: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        ),
      ],
    ),
  ]);

  final ValueNotifier<List<CartItem>> cartNotifier = ValueNotifier([]);
  final ValueNotifier<List<PlatformOrder>> ordersNotifier = ValueNotifier([]);
  String? currentCartStoreId;

  void addToCart(ProductItem product) {
    if (currentCartStoreId != null && currentCartStoreId != product.storeId) {
      cartNotifier.value = [];
    }
    currentCartStoreId = product.storeId;

    final current = List<CartItem>.from(cartNotifier.value);
    final index = current.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      current[index].quantity += 1;
    } else {
      current.add(CartItem(product: product, quantity: 1));
    }
    cartNotifier.value = current;
  }

  void removeFromCart(ProductItem product) {
    final current = List<CartItem>.from(cartNotifier.value);
    final index = current.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (current[index].quantity > 1) {
        current[index].quantity -= 1;
      } else {
        current.removeAt(index);
      }
    }
    if (current.isEmpty) {
      currentCartStoreId = null;
    }
    cartNotifier.value = current;
  }

  void clearCart() {
    cartNotifier.value = [];
    currentCartStoreId = null;
  }

  void addStore(Store store) {
    final list = List<Store>.from(storesNotifier.value);
    list.add(store);
    storesNotifier.value = list;
  }

  void addProductToStore(String storeId, ProductItem product) {
    final list = List<Store>.from(storesNotifier.value);
    final index = list.indexWhere((s) => s.id == storeId);
    if (index >= 0) {
      list[index].products.add(product);
      storesNotifier.value = list;
    }
  }

  void addOrder(PlatformOrder order) {
    final list = List<PlatformOrder>.from(ordersNotifier.value);
    list.insert(0, order);
    ordersNotifier.value = list;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final list = List<PlatformOrder>.from(ordersNotifier.value);
    final index = list.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      list[index].status = newStatus;
      ordersNotifier.value = list;
    }
  }
}

// ============================================================================
// NAVEGAÇÃO PRINCIPAL DO CLIENTE (FEED + MEUS PEDIDOS)
// ============================================================================
class CustomerMainTabsScreen extends StatefulWidget {
  const CustomerMainTabsScreen({super.key});

  @override
  State<CustomerMainTabsScreen> createState() => _CustomerMainTabsScreenState();
}

class _CustomerMainTabsScreenState extends State<CustomerMainTabsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabIndex == 0 ? const MainFeedHomeScreen() : const CustomerOrdersTrackingScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFFEA1D2C)),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFFEA1D2C)),
            label: 'Meus Pedidos',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TELA 1: FEED DE LOJAS E CATEGORIAS (ESTILO IFOOD)
// ============================================================================
class MainFeedHomeScreen extends StatefulWidget {
  const MainFeedHomeScreen({super.key});

  @override
  State<MainFeedHomeScreen> createState() => _MainFeedHomeScreenState();
}

class _MainFeedHomeScreenState extends State<MainFeedHomeScreen> {
  String selectedCategory = 'Tudo';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ENTREGAR EM',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  'Rua Central, 100 - Centro',
                  style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFEA1D2C), size: 18),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store_mall_directory_rounded, color: Color(0xFFEA1D2C)),
            tooltip: 'Portal dos Lojistas',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MerchantPortalSelectionScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRA DE PESQUISA
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar lojas, pratos ou bebidas...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFEA1D2C)),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // CARROSSEL DE CATEGORIAS
            Container(
              color: Colors.white,
              height: 95,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: MarketplaceService.instance.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final cat = MarketplaceService.instance.categories[index];
                  final isSelected = selectedCategory == cat.name;

                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat.name),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isSelected ? const Color(0xFFEA1D2C) : const Color(0xFFF5F5F5),
                          child: Icon(
                            cat.icon,
                            color: isSelected ? Colors.white : Colors.black87,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFEA1D2C) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // TÍTULO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Lojas e Restaurantes Parceiros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            // LISTA DE LOJAS
            ValueListenableBuilder<List<Store>>(
              valueListenable: MarketplaceService.instance.storesNotifier,
              builder: (context, stores, _) {
                final filteredStores = stores.where((s) {
                  final matchesCategory = selectedCategory == 'Tudo' || s.category == selectedCategory;
                  final matchesSearch = s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      s.products.any((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()));
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredStores.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhuma loja encontrada para essa busca.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return _StoreCard(
                      store: store,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StoreDetailsScreen(store: store)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: MarketplaceService.instance.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) return const SizedBox.shrink();

          final totalItems = items.fold(0, (sum, i) => sum + i.quantity);
          final subtotal = items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$totalItems itens na sacola', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('R\$ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA1D2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartCheckoutScreen()),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Ver Sacola'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// CARD DA LOJA NO FEED
// ============================================================================
class _StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SmartImageWidget(
                  imagePath: store.logoPath,
                  width: 68,
                  height: 68,
                  fallbackIcon: Icons.storefront,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text('${store.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(width: 6),
                        Text('•  ${store.category}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(store.deliveryTime, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(width: 6),
                        Text(
                          store.deliveryFee == 0 ? 'Grátis' : '•  R\$ ${store.deliveryFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: store.deliveryFee == 0 ? Colors.green : Colors.black54,
                            fontWeight: store.deliveryFee == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TELA DA LOJA / CARDÁPIO ESPECÍFICO
// ============================================================================
class StoreDetailsScreen extends StatelessWidget {
  final Store store;
  const StoreDetailsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SmartImageWidget(
                imagePath: store.bannerPath,
                fit: BoxFit.cover,
                fallbackIcon: Icons.restaurant,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SmartImageWidget(
                      imagePath: store.logoPath,
                      width: 60,
                      height: 60,
                      fallbackIcon: Icons.store,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${store.category} • ⭐ ${store.rating} • ${store.deliveryTime}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Taxa de entrega: R\$ ${store.deliveryFee.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Cardápio (${store.products.length} itens)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = store.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(product.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(
                                'R\$ ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA1D2C)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SmartImageWidget(
                                imagePath: product.imagePath,
                                width: 70,
                                height: 70,
                                fallbackIcon: Icons.fastfood,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                MarketplaceService.instance.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} adicionado à sacola!'),
                                    duration: const Duration(milliseconds: 900),
                                    backgroundColor: const Color(0xFFEA1D2C),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA1D2C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Adicionar',
                                  style: TextStyle(color: Color(0xFFEA1D2C), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: store.products.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ============================================================================
// CHECKOUT COMPLETO (ENDEREÇO + FORMAS DE PAGAMENTO + FRETE)
// ============================================================================
class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _changeController = TextEditingController();

  String _selectedPayment = 'Pix';
  bool _needChange = false;

  void _finishOrder(Store currentStore, List<CartItem> items, double subtotal) {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha seu Nome e Endereço de Entrega.')),
      );
      return;
    }

    final total = subtotal + currentStore.deliveryFee;

    final newOrder = PlatformOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(8),
      storeId: currentStore.id,
      storeName: currentStore.name,
      customerName: name,
      phone: phone,
      address: address,
      items: List.from(items),
      subtotal: subtotal,
      deliveryFee: currentStore.deliveryFee,
      total: total,
      paymentMethod: _selectedPayment,
      changeFor: _selectedPayment == 'Dinheiro' && _needChange ? _changeController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    MarketplaceService.instance.addOrder(newOrder);
    MarketplaceService.instance.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pedido Realizado!'),
          ],
        ),
        content: Text(
          'Seu pedido #${newOrder.id} foi enviado para ${currentStore.name}.\n\nAcompanhe o status na aba "Meus Pedidos".',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA1D2C)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Acompanhar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: MarketplaceService.instance.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Sua sacola está vazia.'));
          }

          final storeId = MarketplaceService.instance.currentCartStoreId;
          final store = MarketplaceService.instance.storesNotifier.value.firstWhere(
            (s) => s.id == storeId,
            orElse: () => MarketplaceService.instance.storesNotifier.value.first,
          );

          final subtotal = items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));
          final grandTotal = subtotal + store.deliveryFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // RESUMO DA LOJA E ITENS
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loja: ${store.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(height: 16),
                        ...items.map(
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${i.quantity}x ${i.product.name}'),
                                Text('R\$ ${(i.product.price * i.quantity).toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // DADOS DE ENTREGA
                const Text('Endereço de Entrega', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Seu Nome Completo', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'WhatsApp / Telefone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Endereço Completo (Rua, Número, Bairro, Compl.)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // FORMA DE PAGAMENTO
                const Text('Forma de Pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Pix', 'Cartão no Delivery', 'Dinheiro'].map((method) {
                    return ChoiceChip(
                      label: Text(method),
                      selected: _selectedPayment == method,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedPayment = method);
                      },
                    );
                  }).toList(),
                ),

                if (_selectedPayment == 'Dinheiro') ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Precisa de troco?'),
                    value: _needChange,
                    onChanged: (val) => setState(() => _needChange = val),
                  ),
                  if (_needChange)
                    TextField(
                      controller: _changeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: r'Troco para quanto?',
                        prefixText: r'R$ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],

                const SizedBox(height: 20),

                // TOTAIS
                Card(
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('R\$ ${subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Taxa de Entrega:'),
                            Text('R\$ ${store.deliveryFee.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              'R\$ ${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEA1D2C)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA1D2C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _finishOrder(store, items, subtotal),
                  child: Text('Confirmar Pedido (R\$ ${grandTotal.toStringAsFixed(2)})', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// RASTREIO DE PEDIDOS DO CLIENTE COM STEPPER VISUAL
// ============================================================================
class CustomerOrdersTrackingScreen extends StatelessWidget {
  const CustomerOrdersTrackingScreen({super.key});

  int _getStep(String status) {
    switch (status) {
      case 'Pendente':
        return 0;
      case 'Em Preparo':
        return 1;
      case 'Em Rota':
        return 2;
      case 'Entregue':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<PlatformOrder>>(
        valueListenable: MarketplaceService.instance.ordersNotifier,
        builder: (context, orders, _) {
          if (orders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 70, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Você ainda não realizou nenhum pedido.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final currentStep = _getStep(order.status);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.storeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('R\$ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Pedido #${order.id} • Status: ${order.status}', style: const TextStyle(color: Color(0xFFEA1D2C), fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 20),
                      ...order.items.map((i) => Text('• ${i.quantity}x ${i.product.name}')),
                      const SizedBox(height: 16),
                      // STEPPER VISUAL
                      Row(
                        children: [
                          _StatusNode(label: 'Recebido', isActive: currentStep >= 0),
                          Expanded(child: Container(height: 3, color: currentStep >= 1 ? const Color(0xFFEA1D2C) : Colors.grey.shade300)),
                          _StatusNode(label: 'Cozinha', isActive: currentStep >= 1),
                          Expanded(child: Container(height: 3, color: currentStep >= 2 ? Colors.blue : Colors.grey.shade300)),
                          _StatusNode(label: 'Em Rota', isActive: currentStep >= 2),
                          Expanded(child: Container(height: 3, color: currentStep >= 3 ? Colors.green : Colors.grey.shade300)),
                          _StatusNode(label: 'Entregue', isActive: currentStep >= 3, isDone: true),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusNode extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StatusNode({required this.label, required this.isActive, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: isActive ? (isDone ? Colors.green : const Color(0xFFEA1D2C)) : Colors.grey.shade300,
          child: Icon(isActive ? Icons.check : Icons.circle, size: 10, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

// ============================================================================
// PORTAL DO LOJISTA: SELEÇÃO DE LOJA / NOVO CADASTRO
// ============================================================================
class MerchantPortalSelectionScreen extends StatelessWidget {
  const MerchantPortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal do Parceiro'),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<Store>>(
        valueListenable: MarketplaceService.instance.storesNotifier,
        builder: (context, stores, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Selecione sua loja para gerenciar:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...stores.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SmartImageWidget(imagePath: s.logoPath, width: 45, height: 45),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${s.category} • ${s.products.length} itens no cardápio'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MerchantStoreManagerScreen(store: s)),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA1D2C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterStoreScreen()),
                ),
                icon: const Icon(Icons.add_business),
                label: const Text('Cadastrar Novo Estabelecimento'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// PAINEL DE GESTÃO DA LOJA (PEDIDOS EM TEMPO REAL + NOVO PRODUTO COM FOTO)
// ============================================================================
class MerchantStoreManagerScreen extends StatelessWidget {
  final Store store;
  const MerchantStoreManagerScreen({super.key, required this.store});

  void _showAddProductModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String pickedImagePath = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
            if (photo != null) {
              setModalState(() => pickedImagePath = photo.path);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Novo Item no Cardápio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: pickedImagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(pickedImagePath), fit: BoxFit.cover, width: double.infinity),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
                                SizedBox(height: 4),
                                Text('Toque para escolher foto da Galeria', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Prato/Produto', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: r'Preço (R$)', prefixText: r'R$ ', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA1D2C)),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0.0;

                      if (name.isNotEmpty && price > 0) {
                        MarketplaceService.instance.addProductToStore(
                          store.id,
                          ProductItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            storeId: store.id,
                            name: name,
                            description: descCtrl.text.trim(),
                            price: price,
                            imagePath: pickedImagePath,
                          ),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Salvar Produto no Cardápio'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gestão: ${store.name}'),
          backgroundColor: const Color(0xFFEA1D2C),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos Recebidos'),
              Tab(icon: Icon(Icons.menu_book), text: 'Cardápio da Loja'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: PEDIDOS DESTA LOJA
            ValueListenableBuilder<List<PlatformOrder>>(
              valueListenable: MarketplaceService.instance.ordersNotifier,
              builder: (context, orders, _) {
                final storeOrders = orders.where((o) => o.storeId == store.id).toList();

                if (storeOrders.isEmpty) {
                  return const Center(child: Text('Nenhum pedido recebido para este estabelecimento.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: storeOrders.length,
                  itemBuilder: (context, index) {
                    final order = storeOrders[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('PEDIDO #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Chip(label: Text(order.status), backgroundColor: Colors.red.shade50),
                              ],
                            ),
                            Text('Cliente: ${order.customerName} (${order.phone})'),
                            Text('Endereço: ${order.address}'),
                            const Divider(),
                            ...order.items.map((i) => Text('• ${i.quantity}x ${i.product.name}')),
                            const SizedBox(height: 6),
                            Text('Pagamento: ${order.paymentMethod} ${order.changeFor != null ? "(Troco p/ R\$ ${order.changeFor})" : ""}'),
                            Text('Total: R\$ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (order.status == 'Pendente')
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () => MarketplaceService.instance.updateOrderStatus(order.id, 'Em Preparo'),
                                      child: const Text('Iniciar Preparo'),
                                    ),
                                  ),
                                if (order.status == 'Em Preparo')
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
                                      onPressed: () => MarketplaceService.instance.updateOrderStatus(order.id, 'Em Rota'),
                                      child: const Text('Despachar p/ Entrega'),
                                    ),
                                  ),
                                if (order.status == 'Em Rota')
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: () => MarketplaceService.instance.updateOrderStatus(order.id, 'Entregue'),
                                      child: const Text('Confirmar Entrega'),
                                    ),
                                  ),
                                if (order.status == 'Entregue')
                                  const Expanded(
                                    child: Text('✅ Pedido Finalizado e Entregue', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
            ),

            // ABA 2: CARDÁPIO DESTA LOJA
            ValueListenableBuilder<List<Store>>(
              valueListenable: MarketplaceService.instance.storesNotifier,
              builder: (context, stores, _) {
                final current = stores.firstWhere((s) => s.id == store.id, orElse: () => store);

                return Scaffold(
                  body: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: current.products.length,
                    itemBuilder: (context, index) {
                      final p = current.products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SmartImageWidget(imagePath: p.imagePath, width: 50, height: 50),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('R\$ ${p.price.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
                  floatingActionButton: FloatingActionButton.extended(
                    backgroundColor: const Color(0xFFEA1D2C),
                    foregroundColor: Colors.white,
                    onPressed: () => _showAddProductModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Prato'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CADASTRO DE NOVA LOJA COM UPLOAD DE FOTOS DA GALERIA
// ============================================================================
class RegisterStoreScreen extends StatefulWidget {
  const RegisterStoreScreen({super.key});

  @override
  State<RegisterStoreScreen> createState() => _RegisterStoreScreenState();
}

class _RegisterStoreScreenState extends State<RegisterStoreScreen> {
  final _nameCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '5.00');
  final _timeCtrl = TextEditingController(text: '30-45 min');
  String _selectedCategory = 'Lanches';

  String _pickedLogoPath = '';
  String _pickedBannerPath = '';

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (photo != null) {
      setState(() => _pickedLogoPath = photo.path);
    }
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (photo != null) {
      setState(() => _pickedBannerPath = photo.path);
    }
  }

  void _saveStore() {
    final name = _nameCtrl.text.trim();
    final fee = double.tryParse(_feeCtrl.text.replaceAll(',', '.')) ?? 5.00;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do estabelecimento.')),
      );
      return;
    }

    final newStore = Store(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      rating: 5.0,
      deliveryTime: _timeCtrl.text.trim(),
      deliveryFee: fee,
      logoPath: _pickedLogoPath,
      bannerPath: _pickedBannerPath,
      products: [],
    );

    MarketplaceService.instance.addStore(newStore);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nova loja cadastrada com sucesso!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Estabelecimento'),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Fotos da Loja (Galeria)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                // LOGO
                Expanded(
                  child: Column(
                    children: [
                      const Text('Logo / Ícone', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEA1D2C)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _pickedLogoPath.isNotEmpty
                                ? Image.file(File(_pickedLogoPath), fit: BoxFit.cover, width: double.infinity)
                                : const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // BANNER
                Expanded(
                  child: Column(
                    children: [
                      const Text('Foto de Capa (Banner)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickBanner,
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade700),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _pickedBannerPath.isNotEmpty
                                ? Image.file(File(_pickedBannerPath), fit: BoxFit.cover, width: double.infinity)
                                : const Center(child: Icon(Icons.panorama, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Estabelecimento', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Segmento / Categoria', border: OutlineInputBorder()),
              items: ['Lanches', 'Bebidas', 'Pizzas', 'Doces', 'Marmitas', 'Farmácia'].map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _feeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: r'Taxa de Entrega Padrão (R$)', prefixText: r'R$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _timeCtrl,
              decoration: const InputDecoration(labelText: 'Tempo Médio de Entrega', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEA1D2C),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveStore,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Cadastrar e Publicar Loja', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
