import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/kds_provider.dart';
import '../provider/waiterProvider.dart';
import '../model/order_model.dart';
import '../model/vendor_model.dart';

class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends State<KdsScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);
  final Color secondaryColor = const Color(0xFF0F172A);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final kdsProvider = Provider.of<KdsProvider>(context, listen: false);
      final waiterProvider = Provider.of<WaiterProvider>(context, listen: false);

      waiterProvider.listenVendors();
      // Default to "All" (empty string)
      kdsProvider.setVendor('');
      kdsProvider.listenOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final currentVendor = provider.vendorType.isEmpty
        ? VendorModel(id: '', name: 'All Kitchens', icon: '🏪')
        : waiterProvider.vendors.firstWhere(
            (v) => v.id == provider.vendorType,
            orElse: () => VendorModel(id: provider.vendorType, name: 'Kitchen', icon: '🍴'),
          );

    // Calculate Grid Layout for Wrap
    int crossAxisCount = screenWidth > 1400 ? 4 : screenWidth > 1000 ? 3 : screenWidth > 600 ? 2 : 1;
    double horizontalPadding = 24.0;
    double gap = 24.0;
    double cardWidth = (screenWidth - (horizontalPadding * 2) - (gap * (crossAxisCount - 1))) / crossAxisCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "KITCHEN MONITOR".toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    currentVendor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.green, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          _buildActionStat(
            context,
            label: "ACTIVE ORDERS",
            value: "${provider.activeCount}",
            color: primaryColor,
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => provider.setSearchQuery(val),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Search Table or Order ID",
                            hintStyle: TextStyle(color: Colors.blueGrey[300], fontSize: 15),
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.blueGrey[400], size: 22),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            suffixIcon: provider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.cancel_rounded, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearchQuery('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusDropdown(provider),
                  ],
                ),
                const SizedBox(height: 16),
                _VendorBar(provider: provider, vendors: waiterProvider.vendors),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => provider.listenOrders(),
                    color: primaryColor,
                    child: provider.orders.isEmpty
                        ? _EmptyState(
                            activeTab: provider.activeTab,
                            isSearching: provider.searchQuery.isNotEmpty,
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: provider.orders.map((order) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: _TicketWidget(
                                      order: order,
                                      vendorType: provider.vendorType,
                                      onUpdateStatus: (itemIdx, newStatus) => provider.updateItemStatus(
                                        order.id,
                                        itemIdx,
                                        newStatus,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStat(BuildContext context, {required String label, required String value, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color.withOpacity(0.6), letterSpacing: 1)),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(KdsProvider provider) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.activeTab,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          onChanged: (val) => provider.activeTab = val!,
          items: const [
            DropdownMenuItem(value: 'live', child: Text("Status: Live")),
            DropdownMenuItem(value: 'history', child: Text("Status: Completed")),
          ],
        ),
      ),
    );
  }
}

class _VendorBar extends StatelessWidget {
  final KdsProvider provider;
  final List<VendorModel> vendors;
  const _VendorBar({required this.provider, required this.vendors});

  @override
  Widget build(BuildContext context) {
    // Add "All" option to the list
    final List<VendorModel> allVendors = [
      VendorModel(id: '', name: 'ALL KITCHENS', icon: '🏪'),
      ...vendors,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: allVendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final vendor = allVendors[index];
          final isSelected = provider.vendorType == vendor.id;
          return GestureDetector(
            onTap: () => provider.setVendor(vendor.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))] : [],
              ),
              child: Center(
                child: Row(
                  children: [
                    Text(vendor.icon, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Text(
                      vendor.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TicketWidget extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Function(int, String) onUpdateStatus;

  const _TicketWidget({required this.order, required this.vendorType, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    // If vendorType is empty, show all items in the order
    final vendorItems = vendorType.isEmpty 
        ? order.items 
        : order.items.where((i) => i.vendorId == vendorType).toList();
        
    final readyItemsCount = vendorItems.where((i) => i.status == 'ready' || i.status == 'delivered').length;
    final allReady = readyItemsCount == vendorItems.length;
    final isUrgent = waitTime > 15 && !allReady;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isUrgent ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isUrgent ? Colors.red.withOpacity(0.3) : const Color(0xFFE2E8F0),
          width: isUrgent ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: isUrgent ? Colors.red[50]! : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(order.tableNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TABLE UNIT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1)),
                        Text("#${order.id.substring(order.id.length.clamp(0, 4) == 4 ? order.id.length - 4 : 0).toUpperCase()}", 
                             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ],
                ),
                _UrgencyBadge(waitTime: waitTime, isUrgent: isUrgent),
              ],
            ),
          ),

          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vendorItems.length > 1) _buildProgressBar(readyItemsCount, vendorItems.length),
              if (order.notes?.isNotEmpty ?? false) _buildNotes(order.notes!),
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vendorItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = vendorItems[index];
                  final originalIdx = order.items.indexOf(item);
                  return _ItemRow(
                    item: item,
                    onStatusToggle: () => onUpdateStatus(originalIdx, item.status == 'preparing' ? 'ready' : 'preparing'),
                    canEdit: order.status != 'delivered',
                  );
                },
              ),
            ],
          ),

          // Footer
          _TicketFooter(status: order.status, allReady: allReady),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int ready, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PREPARATION", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
              Text("$ready / $total", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ready / total,
              backgroundColor: const Color(0xFFF1F5F9),
              color: Colors.green[500],
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(String notes) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEF3C7))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_rounded, size: 16, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(child: Text(notes, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E), height: 1.3))),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onStatusToggle;
  final bool canEdit;

  const _ItemRow({required this.item, required this.onStatusToggle, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final isReady = item.status == 'ready' || item.status == 'delivered';
    final isPreparing = item.status == 'preparing';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isReady ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isReady ? Colors.green[500] : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
            child: Text("${item.quantity}x", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isReady ? const Color(0xFF166534) : const Color(0xFF1E293B),
                    decoration: isReady ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isReady ? Colors.green[600] : (isPreparing ? Colors.orange[700] : Colors.blueGrey[300]), letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          if (!isReady && canEdit)
            _ActionIcon(onTap: onStatusToggle, isPreparing: isPreparing),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPreparing;
  const _ActionIcon({required this.onTap, required this.isPreparing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPreparing ? Colors.green[600] : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isPreparing ? Icons.check_circle_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final int waitTime;
  final bool isUrgent;
  const _UrgencyBadge({required this.waitTime, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: isUrgent ? Colors.red[100] : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.access_time_filled_rounded, size: 14, color: isUrgent ? Colors.red[700] : Colors.amber[800]),
          const SizedBox(width: 4),
          Text("${waitTime}m", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isUrgent ? Colors.red[700] : Colors.amber[900])),
        ],
      ),
    );
  }
}

class _TicketFooter extends StatelessWidget {
  final String status;
  final bool allReady;
  const _TicketFooter({required this.status, required this.allReady});

  @override
  Widget build(BuildContext context) {
    bool isCompleted = status == 'delivered';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: isCompleted ? const Color(0xFFEFF6FF) : (allReady ? const Color(0xFF22C55E) : const Color(0xFF0F172A))),
      child: Center(
        child: Text(
          isCompleted ? "ORDER COMPLETED" : (allReady ? "READY FOR SERVICE" : "PREPARATION IN PROGRESS"),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isCompleted ? const Color(0xFF1D4ED8) : Colors.white, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String activeTab;
  final bool isSearching;

  const _EmptyState({required this.activeTab, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10))]),
            child: Icon(isSearching ? Icons.search_off_rounded : (activeTab == 'live' ? Icons.restaurant_menu_rounded : Icons.history_rounded), size: 80, color: const Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 30),
          Text(isSearching ? "No results found" : (activeTab == 'live' ? "Everything's Clear!" : "History Empty"), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(isSearching ? "We couldn't find any orders matching your search query." : "New orders will appear here automatically as soon as they are placed.", style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
