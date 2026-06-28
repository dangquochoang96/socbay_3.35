import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/retail_order/retail_order_bloc.dart';
import 'package:socbay/blocs/retail_order/retail_order_event.dart';
import 'package:socbay/blocs/retail_order/retail_order_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/components/qr_reader_view.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class CreateRetailOrderScreen extends StatefulWidget {
  const CreateRetailOrderScreen({super.key});

  @override
  State<CreateRetailOrderScreen> createState() =>
      _CreateRetailOrderScreenState();
}

class _CreateRetailOrderScreenState extends State<CreateRetailOrderScreen> {
  UserModel? _currentUser;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  final List<SelectedProduct> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _currentUser = App.instance.userApp;
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var p in _selectedProducts) {
      p.priceController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorUtil.bangladeshGreen,
              onPrimary: Colors.white,
              onSurface: ColorUtil.raisinBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: ColorUtil.bangladeshGreen,
                onPrimary: Colors.white,
                onSurface: ColorUtil.raisinBlack,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addProduct(ProductModel product) {
    setState(() {
      final index = _selectedProducts.indexWhere(
        (p) => p.product.id == product.id,
      );
      if (index >= 0) {
        _selectedProducts[index].quantity++;
      } else {
        _selectedProducts.add(
          SelectedProduct(
            product: product,
            quantity: 1,
            price: product.priceSale ?? product.price ?? 0,
          ),
        );
      }
    });
    Fluttertoast.showToast(msg: "Đã thêm ${product.name}");
  }

  Future<void> _scanBarcode() async {
    if (await Permission.camera.request().isGranted) {
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
            ApiEndpoints.getProductByBarcode(barcode),
          );
          final response = await http.get(url);
          if (response.statusCode == HttpStatus.ok) {
            final jsonRes = json.decode(response.body);
            if (jsonRes['code'] == 1 && jsonRes['data'] != null) {
              final product = ProductModel.fromJson(jsonRes['data']);
              _addProduct(product);
            } else {
              Fluttertoast.showToast(msg: 'Không tìm thấy sản phẩm với mã này');
            }
          } else {
            Fluttertoast.showToast(msg: 'Lỗi tải thông tin sản phẩm');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: 'Đã xảy ra lỗi: $e');
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
        content: 'Vui lòng cấp quyền truy cập camera.',
      );
    }
  }

  void _openProductSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ProductSearchBottomSheet(
                scrollController: controller,
                onProductSelected: (product) {
                  _addProduct(product);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    if (_selectedProducts.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng chọn ít nhất 1 sản phẩm");
      return;
    }

    final String userId = _currentUser?.id?.toString() ?? "";
    final String name = _currentUser?.username ?? "Chưa cập nhật";
    final String phone = _currentUser?.phone ?? "";
    final String address = "Lấy hàng tại kho";

    final productsJson = _selectedProducts.map((p) {
      return {
        "product_id": p.product.id,
        "quantity": p.quantity,
        "price": p.price,
      };
    }).toList();

    final Map<String, dynamic> body = {
      "user_id": userId,
      "customer_id": userId,
      "sale_id": userId,
      "status": "1",
      "order_user_name": name,
      "order_user_phone": phone,
      "order_user_address": address,
      "notes": _notesController.text.trim(),
      "order_date": DateFormat("yyyy-MM-ddTHH:mm").format(_selectedDate),
      "products_json": jsonEncode(productsJson),
      "is_socbay": "true",
    };

    BlocProvider.of<RetailOrderBloc>(
      context,
    ).add(CreateRetailOrderSubmitEvent(body: body));
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '0 đ';
    try {
      double value = 0;
      if (val is String) {
        value = double.tryParse(val) ?? 0;
      } else if (val is num) {
        value = val.toDouble();
      }
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'đ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    } catch (e) {
      return '$val đ';
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;
    for (var p in _selectedProducts) {
      totalAmount += p.price * p.quantity;
    }

    return BlocConsumer<RetailOrderBloc, RetailOrderState>(
      listener: (context, state) {
        if (state is CreateRetailOrderSuccess) {
          Fluttertoast.showToast(msg: "Tạo đơn hàng thành công");
          Navigator.pop(context, true);
        } else if (state is CreateRetailOrderFailure) {
          Fluttertoast.showToast(msg: state.error);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is CreateRetailOrderLoading;
        return Scaffold(
          appBar: MyAppBar(title: "Tạo đơn bán buôn", isBackNavigation: true),
          backgroundColor: const Color(0xfff7f8fa),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(paddingHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomerInfoCard(),
                          const SizedBox(height: 16),
                          _buildOrderInfoCard(),
                          const SizedBox(height: 16),
                          _buildProductsCard(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(totalAmount),
                ],
              ),
              if (isSubmitting)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfoCard() {
    final name = _currentUser?.username ?? "Chưa cập nhật";
    final phone = _currentUser?.phone ?? "Chưa cập nhật";
    final address = _currentUser?.address ?? "Chưa cập nhật";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle,
                color: ColorUtil.bangladeshGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                "Thông tin nhận hàng",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.raisinBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, "Người nhận", name),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, "Số điện thoại", phone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", address),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: ColorUtil.raisinBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thông tin đơn hàng",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorUtil.raisinBlack,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Ngày đặt hàng",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                  const Icon(Icons.calendar_month, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Ghi chú",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Nhập ghi chú cho đơn hàng...",
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ColorUtil.bangladeshGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sản phẩm",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text("Quét Mã"),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorUtil.bangladeshGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openProductSearch,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text("Thêm"),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorUtil.bangladeshGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_selectedProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Chưa có sản phẩm nào được chọn",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedProducts.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 24, color: Color(0xfff1f2f6)),
              itemBuilder: (context, index) {
                final item = _selectedProducts[index];
                return _buildSelectedProductItem(item, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductItem(SelectedProduct item, int index) {
    final product = item.product;
    String imageUrl = '';
    if (product.images != null && product.images!.isNotEmpty) {
      final link = product.images![0].link;
      if (link != null && link.isNotEmpty) {
        imageUrl = "$protocol${AppConfig.instance.values.apiUrl}$link";
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: const Color(0xfff1f2f6),
            child: imageUrl.isNotEmpty
                ? ImageUtil.loadNetWorkImage(
                    url: imageUrl,
                    height: 60,
                    width: 60,
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? "Sản phẩm",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Đơn giá: ",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: TextField(
                        controller: item.priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.bangladeshGreen,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          suffixText: "đ",
                          suffixStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: ColorUtil.bangladeshGreen,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          final cleanVal = val.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          final parsedPrice = double.tryParse(cleanVal) ?? 0;
                          setState(() {
                            item.price = parsedPrice;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildQtyButton(Icons.remove, () {
                    setState(() {
                      if (item.quantity > 1) {
                        item.quantity--;
                      } else {
                        final removed = _selectedProducts.removeAt(index);
                        removed.priceController.dispose();
                      }
                    });
                  }),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      "${item.quantity}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQtyButton(Icons.add, () {
                    setState(() {
                      item.quantity++;
                    });
                  }),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        final removed = _selectedProducts.removeAt(index);
                        removed.priceController.dispose();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xfff1f2f6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: ColorUtil.raisinBlack),
      ),
    );
  }

  Widget _buildBottomBar(double totalAmount) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tổng tiền",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    _formatCurrency(totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Tạo đơn",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedProduct {
  final ProductModel product;
  int quantity;
  num price;
  final TextEditingController priceController;

  SelectedProduct({
    required this.product,
    required this.quantity,
    required this.price,
  }) : priceController = TextEditingController(
         text: NumberFormat.decimalPattern('vi_VN').format(price),
       );
}

class ProductSearchBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(ProductModel) onProductSelected;

  const ProductSearchBottomSheet({
    super.key,
    required this.scrollController,
    required this.onProductSelected,
  });

  @override
  State<ProductSearchBottomSheet> createState() =>
      _ProductSearchBottomSheetState();
}

class _ProductSearchBottomSheetState extends State<ProductSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<ProductModel> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchProducts(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.productSearch, {
        'q': query,
      });
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var jsonResponse = Map<String, dynamic>.from(json.decode(res.body));
        if (jsonResponse['code'] == 1 && jsonResponse['data'] != null) {
          final dataList = jsonResponse['data']['data'] as List;
          setState(() {
            _searchResults = dataList
                .map((e) => ProductModel.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '0 đ';
    try {
      double value = 0;
      if (val is String) {
        value = double.tryParse(val) ?? 0;
      } else if (val is num) {
        value = val.toDouble();
      }
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'đ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    } catch (e) {
      return '$val đ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tìm kiếm sản phẩm",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Xong",
                  style: TextStyle(
                    color: ColorUtil.bangladeshGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Nhập tên hoặc mã sản phẩm...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xfff1f2f6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ColorUtil.bangladeshGreen,
                  ),
                )
              : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? "Hãy nhập từ khóa để tìm kiếm"
                        : "Không tìm thấy sản phẩm nào",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    final price = product.priceSale ?? product.price ?? 0;

                    String imageUrl = '';
                    if (product.images != null && product.images!.isNotEmpty) {
                      final link = product.images![0].link;
                      if (link != null && link.isNotEmpty) {
                        imageUrl =
                            "$protocol${AppConfig.instance.values.apiUrl}$link";
                      }
                    }

                    return ListTile(
                      onTap: () => widget.onProductSelected(product),
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xfff1f2f6),
                          child: imageUrl.isNotEmpty
                              ? ImageUtil.loadNetWorkImage(
                                  url: imageUrl,
                                  height: 50,
                                  width: 50,
                                )
                              : const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                        ),
                      ),
                      title: Text(
                        product.name ?? "N/A",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _formatCurrency(price),
                        style: const TextStyle(
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: ColorUtil.bangladeshGreen,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    double value = double.tryParse(cleanText) ?? 0;
    final formatter = NumberFormat.decimalPattern('vi_VN');
    String formatted = formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
