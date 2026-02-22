import 'package:flutter/material.dart';
import 'package:rent_x/screens/booking_screen.dart';
import 'package:rent_x/models/car.dart';
import 'package:rent_x/screens/profile_screen.dart';

// Main App Entry Point
void main() {
  runApp(const CarRentalApp());
}

class CarRentalApp extends StatelessWidget {
  const CarRentalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Car Rental',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC107),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}


// Home Screen with Full Functionality
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Car Database
  final List<Car> allCars = [
    Car(
      id: '1',
      name: 'Model S',
      brand: 'Tesla',
      price: '4500',
      rating: '4.9',
      type: 'Electric',
      image: 'assets/images/tesla.jpg',
      transmission: 'Auto',
      seats: '5',
      fuel: 'Electric',
    ),
    Car(
      id: '2',
      name: 'X5',
      brand: 'BMW',
      price: '3800',
      rating: '4.8',
      type: 'SUV',
      image: 'assets/images/bmw.jpg',
      transmission: 'Auto',
      seats: '7',
      fuel: 'Petrol',
    ),
    Car(
      id: '3',
      name: 'A6',
      brand: 'Audi',
      price: '4000',
      rating: '4.7',
      type: 'Sedan',
      image: 'assets/images/Audi.jpg',
      transmission: 'Auto',
      seats: '5',
      fuel: 'Diesel',
    ),
    Car(
      id: '4',
      name: 'Model 3',
      brand: 'Tesla',
      price: '3200',
      rating: '4.8',
      type: 'Electric',
      image: 'assets/images/tesla.jpg',
      transmission: 'Auto',
      seats: '5',
      fuel: 'Electric',
    ),
    Car(
      id: '5',
      name: 'GLE',
      brand: 'Mercedes',
      price: '5000',
      rating: '4.9',
      type: 'Luxury',
      image: 'assets/images/bmw.jpg',
      transmission: 'Auto',
      seats: '5',
      fuel: 'Petrol',
    ),
    Car(
      id: '6',
      name: 'Q7',
      brand: 'Audi',
      price: '4500',
      rating: '4.8',
      type: 'SUV',
      image: 'assets/images/Audi.jpg',
      transmission: 'Auto',
      seats: '7',
      fuel: 'Diesel',
    ),
  ];

  // State Variables
  List<Car> filteredCars = [];
  String selectedFilter = 'All';
  String searchQuery = '';
  final List<String> filters = ['All', 'Electric', 'SUV', 'Sedan', 'Luxury'];
  int selectedNavIndex = 0;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCars = List.from(allCars);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Filter Logic
  void applyFilters() {
    setState(() {
      filteredCars = allCars.where((car) {
        // Apply category filter
        bool matchesFilter = selectedFilter == 'All' || car.type == selectedFilter;

        // Apply search filter
        bool matchesSearch = searchQuery.isEmpty ||
            car.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            car.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
            car.type.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  // Toggle Favorite
  void toggleFavorite(String carId) {
    setState(() {
      final car = allCars.firstWhere((c) => c.id == carId);
      car.isFavorite = !car.isFavorite;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allCars.firstWhere((c) => c.id == carId).isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFFFC107),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Search Handler
  void onSearchChanged(String query) {
    searchQuery = query;
    applyFilters();
  }

  // Filter Selection Handler
  void onFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    applyFilters();
  }

  // Navigation Handler
  void onNavTap(int index) {
    setState(() {
      selectedNavIndex = index;
    });

    // Handle navigation based on index
    if (index == 2) {
      // Show favorites
      setState(() {
        filteredCars = allCars.where((car) => car.isFavorite).toList();
        selectedFilter = 'All';
      });
    } else if (index == 3) {
      // Navigate to Profile Screen 🔥 NEW
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      ).then((_) {
        // Reset navigation when coming back
        setState(() {
          selectedNavIndex = 0;
        });
      });
    } else if (index == 0) {
      // Reset to all cars
      selectedFilter = 'All';
      searchQuery = '';
      searchController.clear();
      applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: _buildSearchBar(),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: _buildFilterChips(),
                  ),

                  // Featured Banner
                  SliverToBoxAdapter(
                    child: _buildFeaturedBanner(),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(),
                  ),

                  // Car Grid or Empty State
                  filteredCars.isEmpty
                      ? SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                      : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: _getAspectRatio(context),
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return _buildCarCard(filteredCars[index]);
                        },
                        childCount: filteredCars.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),

            // Bottom Navigation (Fixed)
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // Responsive Grid Calculations
  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  // double _getAspectRatio(BuildContext context) {
  //   double width = MediaQuery.of(context).size.width;
  //   if (width > 1200) return 0.75;
  //   if (width > 800) return 0.72;
  //   if (width > 600) return 0.70;
  //   return 0.68;
  // }
  double _getAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 0.65;  // was 0.75
    if (width > 800) return 0.62;   // was 0.72
    if (width > 600) return 0.60;   // was 0.70
    return 0.58;  // was 0.68 - this is the key one for mobile
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, User',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find Your Dream Car',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC107),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No new notifications'),
                        duration: Duration(seconds: 1),
                        backgroundColor: Color(0xFF1C1C1C),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for cars...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha:0.4),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha:0.4),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                searchController.clear();
                onSearchChanged('');
              },
            )
                : Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.black,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onFilterSelected(filters[index]);
              },
              backgroundColor: const Color(0xFF1C1C1C),
              selectedColor: const Color(0xFFFFC107),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFFC107)
                    : Colors.white.withValues(alpha:0.1),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 160,
      // Clip.antiAlias prevents children from bleeding over rounded corners
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.directions_car,
              size: 160, // Slightly reduced to fit better
              color: Colors.black.withValues(alpha:0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better distribution
              children: [
                const Text(
                  'Special Offer',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14, // Scaled down slightly
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '30% OFF',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'On your first booking',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha:0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4), // Small controlled gap
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offer applied!'),
                        backgroundColor: Color(0xFFFFC107),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, // Reduced horizontal padding
                      vertical: 8,  // Reduced vertical padding
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedNavIndex == 2
                ? 'Favorite Cars (${filteredCars.length})'
                : 'Premium Collection (${filteredCars.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          if (selectedNavIndex != 2)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Showing all cars'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedNavIndex == 2
                ? Icons.favorite_border
                : Icons.search_off,
            size: 80,
            color: Colors.white.withValues(alpha:0.3),
          ),
          const SizedBox(height: 16),
          Text(
            selectedNavIndex == 2
                ? 'No Favorite Cars'
                : 'No Cars Found',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.7),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedNavIndex == 2
                ? 'Start adding cars to your favorites'
                : 'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(car: car),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha:0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    car.image,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        color: const Color(0xFF2C2C2C),
                        child: const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: Color(0xFFFFC107),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => toggleFavorite(car.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        car.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: car.isFavorite
                            ? const Color(0xFFFFC107)
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Type Badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      car.type,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.brand,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${car.price}',
                                style: const TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'per day',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha:0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha:0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              _buildNavItem(Icons.bookmark_border, 'Saved', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = selectedNavIndex == index;
    return GestureDetector(
      onTap: () => onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFFFC107) : Colors.white.withValues(alpha:0.4),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFFC107) : Colors.white.withValues(alpha:0.4),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Car Details Screen
class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    widget.car.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing car details...'),
                            backgroundColor: Color(0xFFFFC107),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Image
                    Container(
                      height: 250,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF1C1C1C),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.car.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 100,
                                color: Color(0xFFFFC107),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Car Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.car.brand,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha:0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.car.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFFC107),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.car.rating,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Specifications
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSpec(Icons.settings, 'Auto', 'Transmission'),
                              _buildSpec(Icons.airline_seat_recline_normal,
                                  '${widget.car.seats} Seats', 'Capacity'),
                              _buildSpec(Icons.local_gas_station,
                                  widget.car.fuel, 'Fuel Type'),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Price
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price per day',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha:0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${widget.car.price}',
                                      style: const TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            car: widget.car, // 🔥 pass car data
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFC107),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}