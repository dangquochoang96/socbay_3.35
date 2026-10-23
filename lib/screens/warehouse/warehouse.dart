import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:socbay/application.dart';
import 'package:socbay/blocs/warehouse/warehouse_bloc.dart';
import 'package:socbay/blocs/warehouse/warehouse_event.dart';
import 'package:socbay/blocs/warehouse/warehouse_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/warehouse_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/components/qr_reader_view.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';

class WarehouseUI extends StatelessWidget {
  const WarehouseUI({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WarehouseBloc>(
      create: (context) => WarehouseBloc(),
      child: const WarehouseScreen(),
    );
  }
}

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _exportSearchController = TextEditingController();
  final TextEditingController _stockFilterController = TextEditingController();

  List<Warehouse> _allWarehouses = [];
  List<Warehouse> _filteredWarehouseList = [];
  List<OrderWarehouseHistories> _allHistory = [];
  List<OrderWarehouseHistories> _filteredExportHistoryList = [];

  bool _sortDesc = true;
  final Map<int, bool> _expandedCards = {};
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchData(isRefresh: false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _exportSearchController.dispose();
    _stockFilterController.dispose();
    super.dispose();
  }

  void _fetchData({bool isRefresh = false}) {
    final user = App.instance.userApp;
    if (user != null) {
      context.read<WarehouseBloc>().add(
        FetchWarehouseDataEvent(
          userId: user.id.toString(),
          startDate: _fromDate,
          endDate: _toDate,
          isRefresh: isRefresh,
        ),
      );
    }
  }

  void _updateFilteredWarehouseList([String? query]) {
    final searchQuery = query ?? _searchController.text;
    final stockFilterText = _stockFilterController.text.trim();
    final filterStock = int.tryParse(stockFilterText);

    _filteredWarehouseList = _allWarehouses.where((warehouse) {
      final product = warehouse.product;
      final stock = _safeParseInt(warehouse.quantityExist);

      bool nameMatch = true;
      if (searchQuery.trim().isNotEmpty) {
        nameMatch = (product?.name ?? '').toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }

      bool stockMatch = true;
      if (stockFilterText.isNotEmpty && filterStock != null) {
        stockMatch = stock == filterStock;
      }

      return nameMatch && stockMatch;
    }).toList();

    _filteredWarehouseList.sort((a, b) {
      final qa = _safeParseInt(a.quantityExist);
      final qb = _safeParseInt(b.quantityExist);
      return _sortDesc ? qb.compareTo(qa) : qa.compareTo(qb);
    });
  }

  void _filterWarehouseList(String query) {
    setState(() {
      _updateFilteredWarehouseList(query);
    });
  }

  void _updateFilteredExportHistoryList([String? query]) {
    final searchQuery = query ?? _exportSearchController.text;
    if (searchQuery.trim().isEmpty) {
      _filteredExportHistoryList = List.from(_allHistory);
      return;
    }
    _filteredExportHistoryList = _allHistory.where((history) {
      final name = history.userName?.toLowerCase() ?? '';
      final phone = history.userPhone?.toLowerCase() ?? '';
      final verifier = history.verifierName?.toLowerCase() ?? '';
      final verifierPhone = history.verifierPhone?.toLowerCase() ?? '';
      final status = history.statusText?.toLowerCase() ?? '';
      final id = history.id?.toString() ?? '';
      final search = searchQuery.toLowerCase();
      return name.contains(search) ||
          phone.contains(search) ||
          verifier.contains(search) ||
          verifierPhone.contains(search) ||
          status.contains(search) ||
          id.contains(search);
    }).toList();
  }

  void _filterExportHistoryList(String query) {
    setState(() {
      _updateFilteredExportHistoryList(query);
    });
  }

  int _safeParseInt(String? value) {
    if (value == null || value.isEmpty) return 0;
    try {
      return double.parse(value).toInt();
    } catch (_) {
      return 0;
    }
  }

  String _getImageUrl(String? path) {
    if (path == null) return '';
    var cleanPath = path.trim();
    while (cleanPath.isNotEmpty &&
        (cleanPath.startsWith('"') ||
            cleanPath.startsWith("'") ||
            cleanPath.startsWith('[') ||
            cleanPath.startsWith(r'\'))) {
      cleanPath = cleanPath.substring(1).trim();
    }
    while (cleanPath.isNotEmpty &&
        (cleanPath.endsWith('"') ||
            cleanPath.endsWith("'") ||
            cleanPath.endsWith(']') ||
            cleanPath.endsWith(r'\'))) {
      cleanPath = cleanPath.substring(0, cleanPath.length - 1).trim();
    }
    cleanPath = cleanPath.replaceAll('"', '').replaceAll("'", '').trim();
    if (cleanPath.isEmpty) return '';

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    cleanPath = cleanPath.replaceFirst(RegExp(r'^public/'), '');
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    final host = AppConfig.instance.apiHost;
    return '$protocol$host$cleanPath';
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    try {
      double numVal = 0;
      if (value is String) {
        numVal = double.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      } else if (value is num) {
        numVal = value.toDouble();
      }
      return NumberFormat('#,###', 'vi_VN').format(numVal);
    } catch (_) {
      return value.toString();
    }
  }

  String _parseCurrency(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool _isWithin30Days(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return now.difference(date).inDays <= 30;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Fluttertoast.showToast(msg: 'Không thể mở ứng dụng gọi điện');
    }
  }

  void _copyPhoneNumber(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    Fluttertoast.showToast(msg: 'Đã copy số điện thoại');
  }

  Future<void> _handleRefund(OrderWarehouseHistories history) async {
    final bool isHoanKho =
        history.notes != null &&
        history.notes!.toLowerCase().contains('hoàn kho');
    if (isHoanKho) {
      Fluttertoast.showToast(msg: 'Đơn hoàn kho không thể hoàn tác');
      return;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận hoàn tác',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn hoàn tác xuất kho #${history.id}?\n\n'
            'Hành động này sẽ hoàn trả sản phẩm về kho.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hoàn tác',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      context.read<WarehouseBloc>().add(
        RefundWarehouseEvent(historyId: history.id.toString()),
      );
    }
  }

  Future<bool> _showInvoicePreview({
    required Map<String, dynamic> params,
    required List<Map<String, dynamic>> displayProducts,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (previewContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.receipt_long, color: ColorUtil.bangladeshGreen),
                SizedBox(width: 8),
                Text(
                  'Xác nhận xuất kho',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPreviewSection('Khách hàng', [
                      'Tên: ${params['user_name']}',
                      'SĐT: ${params['user_phone']}',
                      'Địa chỉ: ${params['user_address']}',
                    ]),
                    const Divider(height: 24),
                    const Text(
                      'Sản phẩm:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...displayProducts.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${p['quantity']} x ${_formatCurrency(p['price'])} đ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_formatCurrency((double.parse(p['quantity']) * double.parse(p['price'])).toStringAsFixed(0))} đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildPreviewInfoRow(
                      'Tổng tiền hàng',
                      '${_calculateSubTotal(displayProducts)} đ',
                    ),
                    if (params['discount'] != null)
                      _buildPreviewInfoRow(
                        'Chiết khấu',
                        '- ${_formatCurrency(params['discount'])} đ',
                      ),
                    if (params['vat'] != null)
                      _buildPreviewInfoRow(
                        'VAT (${params['vat']}%)',
                        '+ ${_calculateVatAmount(displayProducts, params)} đ',
                      ),
                    const Divider(height: 24),
                    _buildPreviewInfoRow(
                      'Tổng cộng',
                      '${_formatCurrency(params['total_amount']?.toString() ?? '0')} đ',
                      isBold: true,
                      color: Colors.red[700],
                    ),
                    if (params['notes'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Ghi chú: ${params['notes']}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(previewContext, false),
                child: const Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final user = App.instance.userApp;
                  if (user != null) {
                    Navigator.pop(previewContext, false);
                    context.read<WarehouseBloc>().add(
                      ExportWarehouseEvent(
                        userId: user.id.toString(),
                        params: params,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildPreviewSection(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...lines.map(
          (l) => Text(l, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildPreviewInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateSubTotal(List<Map<String, dynamic>> products) {
    double total = 0;
    for (var p in products) {
      total += double.parse(p['quantity']) * double.parse(p['price']);
    }
    return _formatCurrency(total.toStringAsFixed(0));
  }

  String _calculateVatAmount(
    List<Map<String, dynamic>> products,
    Map<String, dynamic> params,
  ) {
    double total = 0;
    for (var p in products) {
      total += double.parse(p['quantity']) * double.parse(p['price']);
    }
    if (params['discount'] != null) {
      double discount = double.tryParse(params['discount'].toString()) ?? 0;
      total -= discount;
    }
    if (params['vat'] != null) {
      double vat = double.parse(params['vat']);
      return _formatCurrency((total * vat / 100).toStringAsFixed(0));
    }
    return '0';
  }

  Future<void> _showExportDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController vatController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController totalPriceController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController searchController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final layerLink = LayerLink();
    List<UserModel> dialogSearchResults = [];
    bool dialogIsSearching = false;
    final FocusNode dialogPhoneFocusNode = FocusNode();
    OverlayEntry? overlayEntry;

    Map<int, int> selectedQuantities = {};
    Map<int, TextEditingController> quantityControllers = {};
    Map<int, TextEditingController> priceControllers = {};
    List<Warehouse> filteredWarehouseList = [];

    for (var warehouse in _allWarehouses) {
      selectedQuantities[warehouse.id] = 0;
      quantityControllers[warehouse.id] = TextEditingController(text: '0');
      final defaultPrice = warehouse.product?.price?.toString() ?? '0';
      priceControllers[warehouse.id] = TextEditingController(
        text: _formatCurrency(defaultPrice),
      );
    }

    void removeOverlay() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    dialogPhoneFocusNode.addListener(() {
      if (!dialogPhoneFocusNode.hasFocus) {
        removeOverlay();
      }
    });

    void dialogSelectUser(UserModel user, StateSetter dialogSetState) {
      dialogSetState(() {
        phoneController.text = user.phone ?? '';
        nameController.text = user.username ?? '';
        addressController.text = user.address ?? '';
        dialogSearchResults.clear();
      });
      dialogPhoneFocusNode.unfocus();
      removeOverlay();
    }

    void showOverlay(BuildContext context, StateSetter dialogSetState) {
      removeOverlay();
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      overlayEntry = OverlayEntry(
        builder: (overlayContext) => Positioned(
          width: size.width - 32,
          child: CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 56),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: dialogSearchResults.length,
                  itemBuilder: (ctx, index) {
                    final user = dialogSearchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorUtil.bangladeshGreen,
                        child: Text(
                          (user.username ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.username ?? 'Chưa cập nhật'),
                      subtitle: Text(user.phone ?? ''),
                      onTap: () => dialogSelectUser(user, dialogSetState),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(overlayEntry!);
    }

    void dialogPhoneChanged(
      String query,
      BuildContext dialogContext,
      StateSetter dialogSetState,
    ) {
      if (query.isEmpty) {
        dialogSetState(() {
          dialogSearchResults.clear();
          dialogIsSearching = false;
        });
        removeOverlay();
        return;
      }

      context.read<WarehouseBloc>().add(SearchCustomerEvent(query: query));
    }

    void updateTotalPrice() {
      double baseTotal = 0;
      selectedQuantities.forEach((warehouseId, quantity) {
        final priceController = priceControllers[warehouseId];
        if (priceController != null &&
            priceController.text.isNotEmpty &&
            quantity > 0) {
          final cleanPrice = _parseCurrency(priceController.text);
          final price = double.tryParse(cleanPrice) ?? 0;
          baseTotal += (price * quantity);
        }
      });

      double discountAmount =
          double.tryParse(_parseCurrency(discountController.text)) ?? 0;
      baseTotal -= discountAmount;

      double vatPercentage = double.tryParse(vatController.text) ?? 0;
      baseTotal += (baseTotal * vatPercentage / 100);

      totalPriceController.text = _formatCurrency(baseTotal.toStringAsFixed(0));
    }

    void setQuantity(
      int warehouseId,
      int qty,
      int maxQuantity,
      StateSetter dialogSetState,
    ) {
      if (qty < 0) qty = 0;
      if (qty > maxQuantity) qty = maxQuantity;
      dialogSetState(() {
        selectedQuantities[warehouseId] = qty;
        quantityControllers[warehouseId]?.text = qty.toString();
      });
      updateTotalPrice();
    }

    final warehouseBloc = context.read<WarehouseBloc>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: warehouseBloc,
        child: StatefulBuilder(
          builder: (dialogStateContext, dialogSetState) {
            return BlocListener<WarehouseBloc, WarehouseState>(
              listener: (blocCtx, state) {
                if (state is UserSearchLoading) {
                  dialogSetState(() {
                    dialogIsSearching = true;
                  });
                } else if (state is UserSearchSuccess) {
                  dialogSetState(() {
                    dialogSearchResults = state.users;
                    dialogIsSearching = false;
                  });
                  if (state.users.isNotEmpty && dialogPhoneFocusNode.hasFocus) {
                    showOverlay(dialogStateContext, dialogSetState);
                  } else {
                    removeOverlay();
                  }
                } else if (state is UserSearchFailure) {
                  dialogSetState(() {
                    dialogIsSearching = false;
                  });
                  removeOverlay();
                }
              },
              child: Dialog.fullscreen(
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: ColorUtil.bangladeshGreen,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        removeOverlay();
                        Navigator.pop(dialogCtx);
                      },
                    ),
                    title: const Text(
                      'Tạo phiếu xuất kho',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Vui lòng điền đầy đủ thông tin khách hàng',
                            );
                            return;
                          }

                          final selectedProductsData = selectedQuantities
                              .entries
                              .where((entry) => entry.value > 0)
                              .map((entry) {
                                final warehouse = _allWarehouses.firstWhere(
                                  (w) => w.id == entry.key,
                                );
                                final customPrice = _parseCurrency(
                                  priceControllers[entry.key]?.text ?? '0',
                                );
                                final price = customPrice.isNotEmpty
                                    ? customPrice
                                    : (warehouse.product?.price?.toString() ??
                                          '0');

                                return {
                                  'product_id': warehouse.product!.id
                                      .toString(),
                                  'quantity': entry.value.toString(),
                                  'price': price,
                                  'name': warehouse.product!.name,
                                };
                              })
                              .toList();

                          if (selectedProductsData.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Vui lòng chọn ít nhất một sản phẩm',
                            );
                            return;
                          }

                          final params = {
                            'products': selectedProductsData
                                .map((p) => p['product_id'])
                                .toList(),
                            'quantities': selectedProductsData
                                .map((p) => p['quantity'])
                                .toList(),
                            'prices': selectedProductsData
                                .map((p) => p['price'])
                                .toList(),
                            'date': DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate),
                            'user_name': nameController.text.trim(),
                            'user_phone': phoneController.text.trim(),
                            'user_address': addressController.text.trim(),
                            'vat': vatController.text.isEmpty
                                ? null
                                : vatController.text,
                            'discount': discountController.text.isEmpty
                                ? null
                                : _parseCurrency(discountController.text),
                            'total_amount': totalPriceController.text.isEmpty
                                ? null
                                : _parseCurrency(totalPriceController.text),
                            'notes': notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          };

                          removeOverlay();
                          Navigator.pop(dialogCtx);
                          await _showInvoicePreview(
                            params: params,
                            displayProducts: selectedProductsData,
                          );
                        },
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin khách hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CompositedTransformTarget(
                          link: layerLink,
                          child: TextField(
                            controller: phoneController,
                            focusNode: dialogPhoneFocusNode,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại *',
                              border: const OutlineInputBorder(),
                              suffixIcon: dialogIsSearching
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (val) => dialogPhoneChanged(
                              val,
                              context,
                              dialogSetState,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên khách hàng *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sản phẩm xuất kho',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                if (await Permission.camera
                                    .request()
                                    .isGranted) {
                                  final barcode = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QrcodeReaderView(
                                        onScan: (result) async {
                                          Navigator.pop(context, result);
                                        },
                                      ),
                                    ),
                                  );
                                  if (barcode != null && barcode.isNotEmpty) {
                                    try {
                                      final url = AppConfig.instance.apiUri(
                                        ApiEndpoints.getProductByBarcode(
                                          barcode,
                                        ),
                                      );
                                      final response = await http.get(url);
                                      if (response.statusCode ==
                                          HttpStatus.ok) {
                                        final jsonRes = json.decode(
                                          response.body,
                                        );
                                        if (jsonRes['code'] == 1 &&
                                            jsonRes['data'] != null) {
                                          final product = ProductModel.fromJson(
                                            jsonRes['data'],
                                          );
                                          final targetId = product.id;

                                          // Tìm sản phẩm trong danh sách kho
                                          final idx = _allWarehouses.indexWhere(
                                            (w) => w.product?.id == targetId,
                                          );
                                          if (idx != -1) {
                                            final warehouse =
                                                _allWarehouses[idx];
                                            final maxQty = _safeParseInt(
                                              warehouse.quantityExist,
                                            );
                                            if (maxQty > 0) {
                                              dialogSetState(() {
                                                int currentQty =
                                                    selectedQuantities[warehouse
                                                        .id] ??
                                                    0;
                                                if (currentQty < maxQty) {
                                                  currentQty++;
                                                  selectedQuantities[warehouse
                                                          .id] =
                                                      currentQty;
                                                  quantityControllers[warehouse
                                                          .id]
                                                      ?.text = currentQty
                                                      .toString();
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Số lượng xuất đã đạt tối đa tồn kho',
                                                  );
                                                }
                                              });
                                              updateTotalPrice();
                                              Fluttertoast.showToast(
                                                msg: 'Đã thêm: ${product.name}',
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Sản phẩm này đã hết hàng trong kho',
                                              );
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Sản phẩm không có trong kho của bạn',
                                            );
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                'Không tìm thấy sản phẩm với mã này',
                                          );
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Lỗi tải thông tin sản phẩm',
                                        );
                                      }
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                        msg: 'Đã xảy ra lỗi: $e',
                                      );
                                    }
                                  }
                                } else {
                                  CustomAlertDialog.show(
                                    context,
                                    leftText: "Cài đặt",
                                    rightText: "Hủy",
                                    isLeftPositive: true,
                                    leftAction: () {
                                      Navigator.pop(context);
                                      openAppSettings();
                                    },
                                    content:
                                        'Vui lòng cấp quyền truy cập camera.',
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: ColorUtil.bangladeshGreen,
                              ),
                              label: const Text(
                                'Quét Mã',
                                style: TextStyle(
                                  color: ColorUtil.bangladeshGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm sản phẩm theo tên hoặc mã...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      dialogSetState(() {
                                        filteredWarehouseList.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            dialogSetState(() {
                              final query = value.trim().toLowerCase();
                              if (query.isEmpty) {
                                filteredWarehouseList.clear();
                              } else {
                                filteredWarehouseList = _allWarehouses.where((
                                  warehouse,
                                ) {
                                  final name = warehouse.product?.name ?? '';
                                  final code =
                                      warehouse.product?.productCode ?? '';
                                  return name.toLowerCase().contains(query) ||
                                      code.toLowerCase().contains(query);
                                }).toList();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final isSearching = searchController.text
                                .trim()
                                .isNotEmpty;
                            final displayedList = isSearching
                                ? filteredWarehouseList
                                : _allWarehouses
                                      .where(
                                        (w) =>
                                            (selectedQuantities[w.id] ?? 0) > 0,
                                      )
                                      .toList();

                            if (displayedList.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isSearching
                                            ? Icons.search_off
                                            : Icons.inventory_2_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isSearching
                                            ? 'Không tìm thấy sản phẩm phù hợp'
                                            : 'Chưa có sản phẩm nào được chọn',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSearching
                                            ? 'Thử tìm kiếm với từ khóa khác'
                                            : 'Quét mã QR hoặc tìm kiếm ở trên để thêm sản phẩm xuất kho',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayedList.length,
                              itemBuilder: (ctx, index) {
                                final warehouse = displayedList[index];
                                final product = warehouse.product;
                                final maxQuantity = _safeParseInt(
                                  warehouse.quantityExist,
                                );
                                final currentQty =
                                    selectedQuantities[warehouse.id] ?? 0;

                                if (isSearching && currentQty == 0) {
                                  // Compact view in search results
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                      title: Text(
                                        product?.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Tồn: $maxQuantity | Giá: ${_formatCurrency(product?.price)} đ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                      trailing: currentQty == 0
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: ColorUtil
                                                    .bangladeshGreen
                                                    .withValues(alpha: 0.1),
                                                foregroundColor:
                                                    ColorUtil.bangladeshGreen,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                minimumSize: const Size(60, 32),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              onPressed: () {
                                                setQuantity(
                                                  warehouse.id,
                                                  1,
                                                  maxQuantity,
                                                  dialogSetState,
                                                );
                                              },
                                              child: const Text(
                                                'Thêm',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      ColorUtil.bangladeshGreen,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      size: 14,
                                                      color: ColorUtil
                                                          .bangladeshGreen,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 28,
                                                          minHeight: 28,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty - 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                  Text(
                                                    '$currentQty',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: ColorUtil
                                                          .bangladeshGreen,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: ColorUtil
                                                          .bangladeshGreen,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 28,
                                                          minHeight: 28,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty + 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  );
                                }

                                // Detailed view for selected items
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product?.name ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                setQuantity(
                                                  warehouse.id,
                                                  0,
                                                  maxQuantity,
                                                  dialogSetState,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tồn kho: $maxQuantity',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Giá bán mặc định: ${_formatCurrency(product?.price)} đ',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty - 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 32,
                                                    child: TextField(
                                                      controller:
                                                          quantityControllers[warehouse
                                                              .id],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                  bottom: 12,
                                                                ),
                                                          ),
                                                      onChanged: (val) {
                                                        int qty =
                                                            int.tryParse(val) ??
                                                            0;
                                                        setQuantity(
                                                          warehouse.id,
                                                          qty,
                                                          maxQuantity,
                                                          dialogSetState,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty + 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Text(
                                              'Giá xuất (đ):',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: TextField(
                                                  controller:
                                                      priceControllers[warehouse
                                                          .id],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                        ),
                                                  ),
                                                  onChanged: (val) {
                                                    final clean =
                                                        _parseCurrency(val);
                                                    if (clean.isNotEmpty) {
                                                      priceControllers[warehouse
                                                              .id]!
                                                          .value = TextEditingValue(
                                                        text: _formatCurrency(
                                                          clean,
                                                        ),
                                                        selection:
                                                            TextSelection.collapsed(
                                                              offset:
                                                                  _formatCurrency(
                                                                    clean,
                                                                  ).length,
                                                            ),
                                                      );
                                                    }
                                                    updateTotalPrice();
                                                  },
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
                            );
                          },
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Chi tiết chi phí',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: vatController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'VAT (%)',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => updateTotalPrice(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Chiết khấu (đ)',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  final clean = _parseCurrency(val);
                                  if (clean.isNotEmpty) {
                                    discountController.value = TextEditingValue(
                                      text: _formatCurrency(clean),
                                      selection: TextSelection.collapsed(
                                        offset: _formatCurrency(clean).length,
                                      ),
                                    );
                                  }
                                  updateTotalPrice();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: totalPriceController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Tổng tiền thanh toán (đ)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              dialogSetState(() => selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày xuất hàng',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                            ),
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
    );

    dialogPhoneFocusNode.dispose();
    removeOverlay();
  }

  Future<void> _showReturnDialog() async {
    DestinationWarehouse? selectedDestinationWarehouse;
    List<DestinationWarehouse> destinationWarehouses = [];
    bool isLoadingWarehouses = true;

    final TextEditingController notesController = TextEditingController();
    final TextEditingController searchController = TextEditingController();
    String? notesError;

    Map<int, int> selectedQuantities = {};
    Map<int, TextEditingController> quantityControllers = {};
    Map<int, TextEditingController> priceControllers = {};
    List<Warehouse> filteredWarehouseList = [];

    for (var warehouse in _allWarehouses) {
      selectedQuantities[warehouse.id] = 0;
      quantityControllers[warehouse.id] = TextEditingController(text: '0');
      final defaultPrice = warehouse.product?.price?.toString() ?? '0';
      priceControllers[warehouse.id] = TextEditingController(
        text: _formatCurrency(defaultPrice),
      );
    }

    void setQuantity(
      int warehouseId,
      int qty,
      int maxQuantity,
      StateSetter dialogSetState,
    ) {
      if (qty < 0) qty = 0;
      if (qty > maxQuantity) qty = maxQuantity;
      dialogSetState(() {
        selectedQuantities[warehouseId] = qty;
        quantityControllers[warehouseId]?.text = qty.toString();
      });
    }

    final warehouseBloc = context.read<WarehouseBloc>();
    warehouseBloc.add(const FetchDestinationWarehousesEvent());

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: warehouseBloc,
        child: StatefulBuilder(
          builder: (dialogStateContext, dialogSetState) {
            return BlocListener<WarehouseBloc, WarehouseState>(
              listener: (blocCtx, state) {
                if (state is DestinationWarehouseLoading) {
                  dialogSetState(() => isLoadingWarehouses = true);
                } else if (state is DestinationWarehouseSuccess) {
                  dialogSetState(() {
                    isLoadingWarehouses = false;
                    destinationWarehouses = state.warehouses;
                    if (destinationWarehouses.isNotEmpty &&
                        selectedDestinationWarehouse == null) {
                      selectedDestinationWarehouse =
                          destinationWarehouses.first;
                    }
                  });
                } else if (state is DestinationWarehouseFailure) {
                  dialogSetState(() => isLoadingWarehouses = false);
                  Fluttertoast.showToast(msg: state.error);
                }
              },
              child: Dialog.fullscreen(
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.orange,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                    title: const Text(
                      'Tạo phiếu hoàn kho',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (selectedDestinationWarehouse == null) {
                            Fluttertoast.showToast(
                              msg: 'Vui lòng chọn kho nhận',
                            );
                            return;
                          }

                          final warehouseId = selectedDestinationWarehouse!.id;

                          final selectedProductsData = selectedQuantities
                              .entries
                              .where((entry) => entry.value > 0)
                              .map((entry) {
                                final warehouse = _allWarehouses.firstWhere(
                                  (w) => w.id == entry.key,
                                );
                                final cleanPrice = _parseCurrency(
                                  priceControllers[entry.key]?.text ?? '0',
                                );
                                final priceNum =
                                    double.tryParse(cleanPrice) ??
                                    double.tryParse(
                                      warehouse.product?.price?.toString() ??
                                          '0',
                                    ) ??
                                    0;
                                final productId =
                                    warehouse.product?.id ??
                                    int.tryParse(warehouse.productId ?? '0') ??
                                    0;

                                return {
                                  'product_id': productId,
                                  'quantity': entry.value,
                                  'price': priceNum,
                                  'name': warehouse.product?.name ?? '',
                                };
                              })
                              .toList();

                          if (selectedProductsData.isEmpty) {
                            Fluttertoast.showToast(
                              msg:
                                  'Vui lòng chọn ít nhất một sản phẩm để hoàn kho',
                            );
                            return;
                          }

                          if (notesController.text.trim().isEmpty) {
                            dialogSetState(() {
                              notesError = 'Vui lòng nhập ghi chú';
                            });
                            Fluttertoast.showToast(
                              msg: 'Vui lòng nhập ghi chú',
                            );
                            return;
                          }

                          final params = {
                            'warehouse_id': warehouseId,
                            'products': selectedProductsData
                                .map((p) => p['product_id'])
                                .toList(),
                            'quantities': selectedProductsData
                                .map((p) => p['quantity'])
                                .toList(),
                            'prices': selectedProductsData
                                .map((p) => p['price'])
                                .toList(),
                            'notes': notesController.text.trim(),
                          };

                          final user = App.instance.userApp;
                          if (user != null) {
                            Navigator.pop(dialogCtx);
                            context.read<WarehouseBloc>().add(
                              ReturnWarehouseEvent(
                                userId: user.id.toString(),
                                params: params,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin hoàn kho',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        isLoadingWarehouses
                            ? const SizedBox(
                                height: 48,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange,
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<DestinationWarehouse>(
                                initialValue: selectedDestinationWarehouse,
                                isExpanded: true,
                                itemHeight: null,
                                decoration: const InputDecoration(
                                  labelText: 'Kho nhận *',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                selectedItemBuilder: (context) {
                                  return destinationWarehouses.map((wh) {
                                    final name = wh.name ?? 'Kho #${wh.id}';
                                    final displayText = name;
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        displayText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList();
                                },
                                items: destinationWarehouses.map((wh) {
                                  return DropdownMenuItem<DestinationWarehouse>(
                                    value: wh,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            wh.name ?? 'Kho #${wh.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (wh.address != null &&
                                              wh.address!.isNotEmpty)
                                            Text(
                                              wh.address!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  dialogSetState(() {
                                    selectedDestinationWarehouse = val;
                                  });
                                },
                              ),

                        const Divider(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sản phẩm hoàn trả',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                if (await Permission.camera
                                    .request()
                                    .isGranted) {
                                  final barcode = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QrcodeReaderView(
                                        onScan: (result) async {
                                          Navigator.pop(context, result);
                                        },
                                      ),
                                    ),
                                  );
                                  if (barcode != null && barcode.isNotEmpty) {
                                    try {
                                      final url = AppConfig.instance.apiUri(
                                        ApiEndpoints.getProductByBarcode(
                                          barcode,
                                        ),
                                      );
                                      final response = await http.get(url);
                                      if (response.statusCode ==
                                          HttpStatus.ok) {
                                        final jsonRes = json.decode(
                                          response.body,
                                        );
                                        if (jsonRes['code'] == 1 &&
                                            jsonRes['data'] != null) {
                                          final product = ProductModel.fromJson(
                                            jsonRes['data'],
                                          );
                                          final targetId = product.id;

                                          final idx = _allWarehouses.indexWhere(
                                            (w) => w.product?.id == targetId,
                                          );
                                          if (idx != -1) {
                                            final warehouse =
                                                _allWarehouses[idx];
                                            final maxQty = _safeParseInt(
                                              warehouse.quantityExist,
                                            );
                                            if (maxQty > 0) {
                                              dialogSetState(() {
                                                int currentQty =
                                                    selectedQuantities[warehouse
                                                        .id] ??
                                                    0;
                                                if (currentQty < maxQty) {
                                                  currentQty++;
                                                  selectedQuantities[warehouse
                                                          .id] =
                                                      currentQty;
                                                  quantityControllers[warehouse
                                                          .id]
                                                      ?.text = currentQty
                                                      .toString();
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Số lượng hoàn đã đạt tối đa tồn kho',
                                                  );
                                                }
                                              });
                                              Fluttertoast.showToast(
                                                msg: 'Đã thêm: ${product.name}',
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Sản phẩm này hiện có 0 số lượng tồn kho',
                                              );
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Sản phẩm không có trong kho của bạn',
                                            );
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                'Không tìm thấy sản phẩm với mã này',
                                          );
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Lỗi tải thông tin sản phẩm',
                                        );
                                      }
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                        msg: 'Đã xảy ra lỗi: $e',
                                      );
                                    }
                                  }
                                } else {
                                  CustomAlertDialog.show(
                                    context,
                                    leftText: "Cài đặt",
                                    rightText: "Hủy",
                                    isLeftPositive: true,
                                    leftAction: () {
                                      Navigator.pop(context);
                                      openAppSettings();
                                    },
                                    content:
                                        'Vui lòng cấp quyền truy cập camera.',
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.orange,
                              ),
                              label: const Text(
                                'Quét Mã',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm sản phẩm theo tên hoặc mã...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      dialogSetState(() {
                                        filteredWarehouseList.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            dialogSetState(() {
                              final query = value.trim().toLowerCase();
                              if (query.isEmpty) {
                                filteredWarehouseList.clear();
                              } else {
                                filteredWarehouseList = _allWarehouses.where((
                                  warehouse,
                                ) {
                                  final name = warehouse.product?.name ?? '';
                                  final code =
                                      warehouse.product?.productCode ?? '';
                                  return name.toLowerCase().contains(query) ||
                                      code.toLowerCase().contains(query);
                                }).toList();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final isSearching = searchController.text
                                .trim()
                                .isNotEmpty;
                            final displayedList = isSearching
                                ? filteredWarehouseList
                                : _allWarehouses
                                      .where(
                                        (w) =>
                                            (selectedQuantities[w.id] ?? 0) > 0,
                                      )
                                      .toList();

                            if (displayedList.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isSearching
                                            ? Icons.search_off
                                            : Icons.inventory_2_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isSearching
                                            ? 'Không tìm thấy sản phẩm phù hợp'
                                            : 'Chưa có sản phẩm nào được chọn',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSearching
                                            ? 'Thử tìm kiếm với từ khóa khác'
                                            : 'Quét mã QR hoặc tìm kiếm ở trên để thêm sản phẩm hoàn kho',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayedList.length,
                              itemBuilder: (ctx, index) {
                                final warehouse = displayedList[index];
                                final product = warehouse.product;
                                final maxQuantity = _safeParseInt(
                                  warehouse.quantityExist,
                                );
                                final currentQty =
                                    selectedQuantities[warehouse.id] ?? 0;

                                if (isSearching && currentQty == 0) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                      title: Text(
                                        product?.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Tồn: $maxQuantity | Giá: ${_formatCurrency(product?.price)} đ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange
                                              .withValues(alpha: 0.1),
                                          foregroundColor: Colors.orange,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          minimumSize: const Size(60, 32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setQuantity(
                                            warehouse.id,
                                            1,
                                            maxQuantity,
                                            dialogSetState,
                                          );
                                        },
                                        child: const Text(
                                          'Thêm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product?.name ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                setQuantity(
                                                  warehouse.id,
                                                  0,
                                                  maxQuantity,
                                                  dialogSetState,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tồn kho hiện tại: $maxQuantity',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Giá mặc định: ${_formatCurrency(product?.price)} đ',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty - 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 32,
                                                    child: TextField(
                                                      controller:
                                                          quantityControllers[warehouse
                                                              .id],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                  bottom: 12,
                                                                ),
                                                          ),
                                                      onChanged: (val) {
                                                        int qty =
                                                            int.tryParse(val) ??
                                                            0;
                                                        setQuantity(
                                                          warehouse.id,
                                                          qty,
                                                          maxQuantity,
                                                          dialogSetState,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32,
                                                        ),
                                                    onPressed: () {
                                                      setQuantity(
                                                        warehouse.id,
                                                        currentQty + 1,
                                                        maxQuantity,
                                                        dialogSetState,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Text(
                                              'Giá hoàn (đ):',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: TextField(
                                                  controller:
                                                      priceControllers[warehouse
                                                          .id],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                        ),
                                                  ),
                                                  onChanged: (val) {
                                                    final clean =
                                                        _parseCurrency(val);
                                                    if (clean.isNotEmpty) {
                                                      priceControllers[warehouse
                                                              .id]!
                                                          .value = TextEditingValue(
                                                        text: _formatCurrency(
                                                          clean,
                                                        ),
                                                        selection:
                                                            TextSelection.collapsed(
                                                              offset:
                                                                  _formatCurrency(
                                                                    clean,
                                                                  ).length,
                                                            ),
                                                      );
                                                    }
                                                  },
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
                            );
                          },
                        ),
                        const Divider(height: 32),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Ghi chú *',
                            hintText: 'Nhập ghi chú hoàn kho...',
                            border: const OutlineInputBorder(),
                            errorText: notesError,
                          ),
                          onChanged: (val) {
                            if (notesError != null && val.trim().isNotEmpty) {
                              dialogSetState(() {
                                notesError = null;
                              });
                            }
                          },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: MyAppBar(
        title: 'Quản lý kho',
        isBackNavigation: true,
        actionWidgets: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () => _fetchData(isRefresh: true),
          ),
        ],
      ),
      body: BlocListener<WarehouseBloc, WarehouseState>(
        listener: (context, state) {
          if (state is ExportWarehouseSuccess) {
            Fluttertoast.showToast(msg: 'Xuất kho thành công');
            _fetchData(isRefresh: true);
          } else if (state is ExportWarehouseFailure) {
            Fluttertoast.showToast(msg: state.error);
          } else if (state is RefundWarehouseSuccess) {
            Fluttertoast.showToast(msg: 'Hoàn tác xuất kho thành công');
            _fetchData(isRefresh: true);
          } else if (state is RefundWarehouseFailure) {
            Fluttertoast.showToast(msg: state.error);
          } else if (state is ReturnWarehouseSuccess) {
            Fluttertoast.showToast(msg: state.message);
            _fetchData(isRefresh: true);
          } else if (state is ReturnWarehouseFailure) {
            Fluttertoast.showToast(msg: state.error);
          }
        },
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: ColorUtil.bangladeshGreen,
                labelColor: ColorUtil.bangladeshGreen,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Tồn kho'),
                  Tab(text: 'Lịch sử xuất'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildWarehouseTab(), _buildHistoryTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btnReturnWarehouse',
            onPressed: _showReturnDialog,
            backgroundColor: Colors.green,
            icon: const Icon(
              Icons.assignment_return_outlined,
              color: Colors.white,
            ),
            label: const Text(
              'Hoàn kho',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'btnExportWarehouse',
            onPressed: _showExportDialog,
            backgroundColor: ColorUtil.brightYellow,
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            label: const Text(
              'Xuất kho',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseTab() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      buildWhen: (prev, curr) =>
          curr is WarehouseLoading ||
          curr is WarehouseLoadSuccess ||
          curr is WarehouseLoadFailure,
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorUtil.bangladeshGreen),
          );
        }

        if (state is WarehouseLoadFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _fetchData(isRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtil.bangladeshGreen,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is WarehouseLoadSuccess) {
          _allWarehouses = state.warehouseData.dataWasehouse ?? [];
          _updateFilteredWarehouseList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            hintText: 'Tìm kiếm sản phẩm...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          onChanged: _filterWarehouseList,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      height: 40,
                      child: TextField(
                        controller: _stockFilterController,
                        style: const TextStyle(fontSize: 13),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          hintText: 'Lọc tồn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: _filterWarehouseList,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _sortDesc ? Icons.arrow_downward : Icons.arrow_upward,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortDesc = !_sortDesc;
                          _filterWarehouseList(_searchController.text);
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: ColorUtil.bangladeshGreen,
                  onRefresh: () async => _fetchData(isRefresh: true),
                  child: _filteredWarehouseList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'Không tìm thấy sản phẩm nào trong kho',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          itemCount: _filteredWarehouseList.length,
                          itemBuilder: (ctx, index) {
                            final item = _filteredWarehouseList[index];
                            final product = item.product;
                            final stock = _safeParseInt(item.quantityExist);
                            final imageUrl = _getImageUrl(
                              product?.images?.isNotEmpty == true
                                  ? product?.images![0].link
                                  : null,
                            );

                            Color accentColor = ColorUtil.bangladeshGreen;
                            if (stock <= 0) {
                              accentColor = Colors.grey;
                            } else if (stock < 5) {
                              accentColor = Colors.orange;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(width: 5, color: accentColor),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey.shade100,
                                                  child: imageUrl.isNotEmpty
                                                      ? CachedNetworkImage(
                                                          imageUrl: imageUrl,
                                                          fit: BoxFit.cover,
                                                          placeholder: (_, _) => Container(
                                                            color: Colors
                                                                .grey
                                                                .shade100,
                                                            child: const Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget:
                                                              (
                                                                _,
                                                                _,
                                                                _,
                                                              ) => const Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        )
                                                      : const Icon(
                                                          Icons.image_outlined,
                                                          color: Colors.grey,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product?.name ??
                                                          'Sản phẩm không tên',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Mã: ${product?.productCode ?? 'N/A'}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    if (item.quantityPrices !=
                                                            null &&
                                                        item
                                                            .quantityPrices!
                                                            .isNotEmpty)
                                                      ...item.quantityPrices!.map(
                                                        (qp) => Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                bottom: 2,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                '≥ ${qp.quantity} sp: ',
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${_formatCurrency(qp.price)} đ',
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Text(
                                                        'Giá: ${_formatCurrency(product?.price)} đ',
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  _buildBadge(
                                                    'Tồn: $stock',
                                                    accentColor.withValues(
                                                      alpha: 0.1,
                                                    ),
                                                    accentColor,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Xuất: ${item.quantityExport ?? '0'}',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 11,
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
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }

  Widget _buildHistoryTab() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      buildWhen: (prev, curr) =>
          curr is WarehouseLoading ||
          curr is WarehouseLoadSuccess ||
          curr is WarehouseLoadFailure,
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorUtil.bangladeshGreen),
          );
        }

        if (state is WarehouseLoadFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _fetchData(isRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtil.bangladeshGreen,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is WarehouseLoadSuccess) {
          _allHistory = state.warehouseData.dataHistory ?? [];
          _updateFilteredExportHistoryList();

          final stats = state.statistic;

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          final DateTimeRange? picked =
                              await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDateRange: DateTimeRange(
                                  start: _fromDate,
                                  end: _toDate,
                                ),
                              );
                          if (picked != null) {
                            setState(() {
                              _fromDate = picked.start;
                              _toDate = picked.end;
                            });
                            _fetchData(isRefresh: true);
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xfff7f8fa),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: ColorUtil.bangladeshGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(_fromDate)} - ${DateFormat('dd/MM/yyyy').format(_toDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Đổi ngày',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorUtil.bangladeshGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: ColorUtil.bangladeshGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Tổng đơn xuất',
                              '${stats?.totalOrder ?? 0}',
                              Colors.orange.shade800,
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatItem(
                              'Doanh thu',
                              stats?.formattedPrice() ?? '0 đ',
                              ColorUtil.bangladeshGreen,
                              icon: Icons.attach_money_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _exportSearchController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm tên hoặc SĐT khách hàng...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 16),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            filled: true,
                            fillColor: const Color(0xfff9fafb),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.8,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: ColorUtil.bangladeshGreen,
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: _filterExportHistoryList,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: ColorUtil.bangladeshGreen,
                  onRefresh: () async => _fetchData(isRefresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredExportHistoryList.length,
                    itemBuilder: (ctx, index) {
                      final history = _filteredExportHistoryList[index];
                      return _buildHistoryCard(history);
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistoryStatusBadge(OrderWarehouseHistories history) {
    final statusText =
        history.statusText ??
        (history.status == 1 ? 'Đã xác nhận' : 'Chưa xác nhận');
    Color bgColor;
    Color textColor;

    switch (history.status) {
      case 1:
        bgColor = const Color(0xff4caf50).withValues(alpha: 0.12);
        textColor = const Color(0xff4caf50);
        break;
      case 0:
        bgColor = Colors.orange.withValues(alpha: 0.12);
        textColor = Colors.orange.shade800;
        break;
      case -1:
        bgColor = Colors.red.withValues(alpha: 0.12);
        textColor = Colors.red;
        break;
      default:
        final lower = statusText.toLowerCase();
        if (lower.contains('đã xác nhận') || lower.contains('thành công')) {
          bgColor = const Color(0xff4caf50).withValues(alpha: 0.12);
          textColor = const Color(0xff4caf50);
        } else if (lower.contains('chưa') || lower.contains('chờ')) {
          bgColor = Colors.orange.withValues(alpha: 0.12);
          textColor = Colors.orange.shade800;
        } else if (lower.contains('hủy') || lower.contains('từ chối')) {
          bgColor = Colors.red.withValues(alpha: 0.12);
          textColor = Colors.red;
        } else {
          bgColor = Colors.blue.withValues(alpha: 0.12);
          textColor = Colors.blue;
        }
    }

    return _buildBadge(statusText, bgColor, textColor);
  }

  Widget _buildHistoryImages(List<String> images, {dynamic historyId}) {
    final validImages = images
        .map((e) => _getImageUrl(e))
        .where((url) => url.isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 56,
      child: PageStorage(
        bucket: PageStorageBucket(),
        child: ListView.separated(
          key: PageStorageKey<String>(
            'history_images_${historyId ?? validImages.hashCode}',
          ),
          scrollDirection: Axis.horizontal,
          itemCount: validImages.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, idx) {
            final imageUrl = validImages[idx];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black87,
                            child: InteractiveViewer(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => Container(
                                  color: Colors.black26,
                                  height: 260,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Không thể tải hình ảnh',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade100,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(OrderWarehouseHistories history) {
    final bool isExpanded = _expandedCards[history.id ?? 0] ?? false;
    final bool isHoanKho =
        history.notes != null &&
        history.notes!.toLowerCase().contains('hoàn kho');
    final confirmImagesList =
        (history.confirmImages != null && history.confirmImages!.isNotEmpty)
        ? history.confirmImages!
        : (history.images ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpanded
              ? ColorUtil.bangladeshGreen.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: ValueKey<int>(history.id ?? 0),
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          childrenPadding: EdgeInsets.zero,
          onExpansionChanged: (val) {
            setState(() {
              _expandedCards[history.id ?? 0] = val;
            });
          },
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300, width: 0.7),
                ),
                child: Text(
                  '#${history.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (isHoanKho) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Hoàn kho',
                    style: TextStyle(
                      color: Color(0xFF5E35B1),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              _buildHistoryStatusBadge(history),
              const Spacer(),
              Text(
                '${_formatCurrency(history.totalAmount)} đ',
                style: TextStyle(
                  color: isHoanKho
                      ? const Color(0xFF5E35B1)
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 13,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          history.userName?.isNotEmpty == true
                              ? history.userName!
                              : 'Khách lẻ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (history.products != null &&
                          history.products!.isNotEmpty) ...[
                        Text(
                          ' • ${history.products!.length} SP',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat(
                        'dd/MM/yy HH:mm',
                      ).format(history.date ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 18,
            color: Colors.grey.shade600,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  if ((history.userPhone != null &&
                          history.userPhone != '0' &&
                          history.userPhone!.isNotEmpty) ||
                      (history.userAddress != null &&
                          history.userAddress!.isNotEmpty)) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff9fafb),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.6,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (history.userPhone != null &&
                              history.userPhone != '0' &&
                              history.userPhone!.isNotEmpty)
                            InkWell(
                              onTap: () => _makePhoneCall(history.userPhone!),
                              onLongPress: () =>
                                  _copyPhoneNumber(history.userPhone!),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 13,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    history.userPhone!,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.copy,
                                    size: 11,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          if (history.userPhone != null &&
                              history.userPhone != '0' &&
                              history.userPhone!.isNotEmpty &&
                              history.userAddress != null &&
                              history.userAddress!.isNotEmpty)
                            const SizedBox(height: 4),
                          if (history.userAddress != null &&
                              history.userAddress!.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    history.userAddress!,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (history.statusText != null ||
                      history.verifierName != null ||
                      (history.verifierPhone != null &&
                          history.verifierPhone != '0') ||
                      confirmImagesList.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xfff7f8fa),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.7,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_outlined,
                                size: 14,
                                color: ColorUtil.bangladeshGreen,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Thông tin kiểm duyệt',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                          if (history.verifierName != null &&
                              history.verifierName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Người duyệt: ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  history.verifierName!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (history.verifierPhone != null &&
                                    history.verifierPhone!.isNotEmpty &&
                                    history.verifierPhone != '0') ...[
                                  const Text(
                                    ' • ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _makePhoneCall(history.verifierPhone!),
                                    child: Text(
                                      history.verifierPhone!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          if (confirmImagesList.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _buildHistoryImages(
                              confirmImagesList,
                              historyId: history.id,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Text(
                    'Sản phẩm xuất:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (history.products != null)
                    ...history.products!.map(
                      (product) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 32,
                                height: 32,
                                color: Colors.grey.shade100,
                                child:
                                    product.image != null &&
                                        product.image!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _getImageUrl(product.image),
                                        fit: BoxFit.cover,
                                        placeholder: (_, _) => Container(
                                          color: Colors.grey.shade100,
                                        ),
                                        errorWidget: (_, _, _) => const Icon(
                                          Icons.image_outlined,
                                          size: 16,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'SL: ${product.quantity} x ${_formatCurrency(product.price)} đ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_formatCurrency((double.tryParse((product.price ?? '').replaceAll(RegExp(r'[^\d]'), '')) ?? 0) * (product.quantity ?? 1))} đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 12),
                  if (history.vat != null &&
                      history.vat != '0' &&
                      history.vat != '0.00')
                    _buildFeeRow('VAT', '${history.vat} %'),
                  if (history.discount != null && history.discount != '0')
                    _buildFeeRow(
                      'Chiết khấu',
                      '- ${_formatCurrency(history.discount)} đ',
                    ),
                  _buildFeeRow(
                    'Tổng thanh toán',
                    '${_formatCurrency(history.totalAmount)} đ',
                    isBold: true,
                  ),
                  if (history.notes != null && history.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isHoanKho
                            ? const Color(0xFFF3E5F5)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isHoanKho
                              ? const Color(0xFFCE93D8)
                              : const Color(0xFFFFE082),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isHoanKho ? Icons.undo : Icons.note_alt_outlined,
                            size: 13,
                            color: isHoanKho
                                ? const Color(0xFF7B1FA2)
                                : Colors.amber.shade900,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Ghi chú: ${history.notes}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isHoanKho
                                    ? const Color(0xFF4A148C)
                                    : Colors.brown.shade800,
                                fontWeight: isHoanKho
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_isWithin30Days(history.date) && !isHoanKho) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleRefund(history),
                        icon: const Icon(
                          Icons.undo,
                          size: 14,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Hoàn tác xuất kho',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Colors.red, width: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
