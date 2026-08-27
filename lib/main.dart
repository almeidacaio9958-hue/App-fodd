import 'package:flutter/material.dart';

void main() {
  runApp(const MarketplaceFoodApp());
}

class MarketplaceFoodApp extends StatelessWidget {
  const MarketplaceFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEA1D2C), // Vermelho clássico iFood
          primary: const Color(0xFFEA1D2C),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const MainHomeScreen(),
    );
  }
}

// ==========================================
// MODELOS DE DADOS
// ==========================================
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
  final String imageUrl;

  ProductItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class Store {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String logoUrl;
  final String bannerUrl;
  final bool isOpen;
  final List<ProductItem> products;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.logoUrl,
    required this.bannerUrl,
    this.isOpen = true,
    required this.products,
  });
}

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// ==========================================
// ESTADO GLOBAL (MOCK / IN-MEMORY)
// ==========================================
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
  ];

  final ValueNotifier<List<Store>> storesNotifier = ValueNotifier([
    Store(
      id: '1',
      name: 'Burger & Cia Gourmet',
      category: 'Lanches',
      rating: 4.8,
      deliveryTime: '30-45 min',
      deliveryFee: 5.99,
      logoUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=300',
      bannerUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=800',
      products: [
        ProductItem(
          id: 'p1',
          storeId: '1',
          name: 'Smash Bacon Duplo',
          description: '2 burgers de 90g, muito queijo cheddar e bacon crocante.',
          price: 28.90,
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        ),
        ProductItem(
          id: 'p2',
          storeId: '1',
          name: 'Batata Rústica c/ Cheddar',
          description: 'Porção individual com molho da casa.',
          price: 16.00,
          imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
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
      logoUrl: 'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?w=300',
      bannerUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800',
      products: [
        ProductItem(
          id: 'p3',
          storeId: '2',
          name: 'Combo Vodka + 4 Energéticos',
          description: 'Vodka Importada 1L + 4 latas de energético.',
          price: 89.90,
          imageUrl: 'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?w=400',
        ),
        ProductItem(
          id: 'p4',
          storeId: '2',
          name: 'Cerveja Puro Malte (Pack 12)',
          description: 'Pack latas 350ml trincando.',
          price: 49.90,
          imageUrl: 'https://images.unsplash.com/photo-1608270199144-8463e2609072?w=400',
        ),
      ],
    ),
    Store(
      id: '3',
      name: 'Pizzaria Bella Fornada',
      category: 'Pizzas',
      rating: 4.7,
      deliveryTime: '40-55 min',
      deliveryFee: 7.50,
      logoUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300',
      bannerUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
      products: [
        ProductItem(
          id: 'p5',
          storeId: '3',
          name: 'Pizza Calabresa Especial',
          description: 'Molho artesanal, mussarela, calabresa e cebola fatiada.',
          price: 52.00,
          imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        ),
      ],
    ),
  ]);

  final ValueNotifier<List<CartItem>> cartNotifier = ValueNotifier([]);
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

  void addStore(Store store) {
    final list = List<Store>.from(storesNotifier.value);
    list.add(store);
    storesNotifier.value = list;
  }
}

// ==========================================
// TELA PRINCIPAL (FEED ESTILO IFOOD)
// ==========================================
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
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
          children: [
            const Text(
              'ENTREGAR EM',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Row(
              children: const [
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
            tooltip: 'Cadastrar Minha Loja',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterStoreScreen()),
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
                  hintText: 'Buscar lojas ou produtos...',
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

            // TÍTULO DA LISTA DE LOJAS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Lojas e Restaurantes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            // LISTA DE LOJAS CADASTRADAS
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
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Nenhuma loja encontrada.', style: TextStyle(color: Colors.grey)),
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
                    Text('$totalItems itens no carrinho', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

// ==========================================
// CARD DA LOJA NO FEED
// ==========================================
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
                child: Image.network(
                  store.logoUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68,
                    height: 68,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.storefront, color: Colors.grey),
                  ),
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

// ==========================================
// TELA DA LOJA / CARDÁPIO ESPECÍFICO
// ==========================================
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
              background: Image.network(
                store.bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEA1D2C)),
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
                    child: Image.network(
                      store.logoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 40),
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
                              child: Image.network(
                                product.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey.shade200),
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

// ==========================================
// TELA DE CADASTRO DE NOVA LOJA (ADMIN)
// ==========================================
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
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300',
      bannerUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      products: [
        ProductItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          storeId: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Item Inicial da Loja',
          description: 'Personalize no painel de produtos.',
          price: 25.00,
          imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        ),
      ],
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
        title: const Text('Cadastrar Nova Loja'),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Parceria Multi-Lojas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Adicione restaurantes, adegas e comércios da sua região ao app.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Estabelecimento', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Segmento / Categoria', border: OutlineInputBorder()),
              items: ['Lanches', 'Bebidas', 'Pizzas', 'Doces', 'Marmitas'].map((cat) {
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

// ==========================================
// TELA DA SACOLA / FINALIZAR PEDIDO
// ==========================================
class CartCheckoutScreen extends StatelessWidget {
  const CartCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Sacola'),
        backgroundColor: const Color(0xFFEA1D2C),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: MarketplaceService.instance.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Sua sacola está vazia.'));
          }

          final subtotal = items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        title: Text(item.product.name),
                        subtitle: Text('R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => MarketplaceService.instance.removeFromCart(item.product),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('R\$ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA1D2C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    MarketplaceService.instance.cartNotifier.value = [];
                    MarketplaceService.instance.currentCartStoreId = null;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido enviado com sucesso para a loja!'), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text('Confirmar e Enviar Pedido', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
