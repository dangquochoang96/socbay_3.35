import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../../blocs/user_Information/customer_information_list_bloc.dart';
import '../../../blocs/user_Information/customer_information_list_event.dart';
import '../../../blocs/user_Information/customer_information_list_state.dart';
import '../../../data/model/user_profile.dart';
import '../../../routes.dart';
import '../../../utils/color_util.dart';

class CustomerInformationListScreen extends StatefulWidget {
  const CustomerInformationListScreen({super.key});

  @override
  State<CustomerInformationListScreen> createState() =>
      _CustomerInformationListScreenState();
}

class _CustomerInformationListScreenState
    extends State<CustomerInformationListScreen> {
  late CustomerInformationListBloc _bloc;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<UserProfile> _filteredUsers = [];

  late final UserProfile? iss;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(CustomerInformationListStartEvent());
    super.initState();
  }

  void _filterUsers() {
    final String nameFilter = _normalizeString(_nameController.text);
    final String phoneFilter = _normalizeString(_phoneController.text);
    final String addressFilter = _normalizeString(_addressController.text);

    setState(() {
      if (nameFilter.isEmpty && phoneFilter.isEmpty && addressFilter.isEmpty) {
        _filteredUsers = _bloc.users;
      } else {
        _filteredUsers = _bloc.users.where((element) {
          if (element.username != null && nameFilter.isNotEmpty) {
            return _compareStrings(element.username!, nameFilter);
          } else if (element.phone != null && phoneFilter.isNotEmpty) {
            return _compareStrings(element.phone!, phoneFilter);
          } else if (element.address != null && addressFilter.isNotEmpty) {
            return _compareStrings(element.address!, addressFilter);
          }
          return false;
        }).toList();
        print("#######");
        print(jsonEncode(_filteredUsers));
      }
    });
  }

  bool _compareStrings(String string1, String string2) {
    var normalizedString1 = removeDiacritics(string1.toLowerCase());
    var normalizedString2 = removeDiacritics(string2.toLowerCase());

    return normalizedString1.contains(normalizedString2);
  }

  String removeDiacritics(String input) {
    const diacritics =
        'áàảãạăắằẳẵặââấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ';
    const plainChars =
        'aaaaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuuyyyyyd';

    for (int i = 0; i < diacritics.length; i++) {
      input = input.replaceAll(
        RegExp(diacritics[i], caseSensitive: false),
        plainChars[i],
      );
    }
    input = input.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    return input;
  }

  String _normalizeString(String input) {
    return input;
  }

  void _onEditInfo() {
    FocusScope.of(context).unfocus();
    if (_nameController.text.isNotEmpty) {
      _bloc.add(CustomerInformationListSearchEvent(name: _nameController.text));
    } else if (_phoneController.text.isNotEmpty) {
      _bloc.add(
        CustomerInformationListSearchEvent(phone: _phoneController.text),
      );
    } else if (_addressController.text.isNotEmpty) {
      _bloc.add(
        CustomerInformationListSearchEvent(address: _addressController.text),
      );
    } else {
      _bloc.add(CustomerInformationListStartEvent());
    }
    _filterUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CustomerInformationListBloc,
      CustomerInformationListState
    >(builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, CustomerInformationListState state) {
    if (state is CustomerInformationListLoadedState) {
      _filterUsers();
    }
  }

  Widget _builder(BuildContext context, CustomerInformationListState state) {
    return Scaffold(
      appBar: MyAppBar(title: "Thông tin khách hàng", isBackNavigation: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(CustomerInformationListStartEvent());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildSearchFormCard(),
                      const SizedBox(height: 12),
                      _buildSearchButton(),
                      const SizedBox(height: 16),
                      _buildResultsHeader(),
                    ],
                  ),
                ),
              ),
              if (_filteredUsers.isEmpty)
                SliverToBoxAdapter(child: _buildNoResults())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      return _buildCustomerCard(
                        _filteredUsers[index],
                        index + 1,
                      );
                    }, childCount: _filteredUsers.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFormCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: ColorUtil.bangladeshGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Bộ lọc tìm kiếm",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputField(
              placeholder: "Họ và tên",
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              placeholder: "Số điện thoại",
              controller: _phoneController,
              icon: Icons.phone_android_rounded,
              inputType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 12),
            _buildInputField(
              placeholder: "Địa chỉ",
              controller: _addressController,
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String placeholder,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: ColorUtil.bangladeshGreen, size: 22),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        counterText: "",
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorUtil.bangladeshGreen,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorUtil.bangladeshGreen,
      ),
      child: TextButton.icon(
        onPressed: _onEditInfo,
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text(
          "TÌM KIẾM",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Kết quả tìm kiếm",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_filteredUsers.length} khách hàng",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorUtil.bangladeshGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy khách hàng nào",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(UserProfile item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: ColorUtil.bangladeshGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$index",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.username ?? "Chưa có tên",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToDetails(item),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Chi tiết",
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorUtil.bangladeshGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: ColorUtil.bangladeshGreen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1, thickness: 0.5),
              ),
              _buildContactRow(
                icon: Icons.phone_in_talk_rounded,
                value: item.phone ?? "Chưa có số điện thoại",
                onCopy: () =>
                    _copyToClipboard(item.phone ?? "", "Số điện thoại"),
              ),
              const SizedBox(height: 8),
              _buildContactRow(
                icon: Icons.location_on_rounded,
                value: item.address ?? "Chưa có địa chỉ",
                onCopy: () => _copyToClipboard(item.address ?? "", "Địa chỉ"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String value,
    required VoidCallback onCopy,
  }) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.copy_rounded, color: Colors.grey.shade400, size: 14),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(UserProfile item) {
    int? seclt = item.id;
    String? phonee = item.phone;
    Navigator.pushNamed(
      context,
      Routes.histoyridCScreen,
      arguments: {'id': seclt, 'phone': phonee},
    );
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text("Đã sao chép $label"),
            ],
          ),
          backgroundColor: ColorUtil.bangladeshGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }
}
