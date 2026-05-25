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
          RegExp(diacritics[i], caseSensitive: false), plainChars[i]);
    }
    input = input.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    return input;
  }

  String _normalizeString(String input) {
    return input;
  }

  void _onEditInfo() {
    if (_nameController.text.isNotEmpty) {
      _bloc.add(CustomerInformationListSearchEvent(name: _nameController.text));
    } else if (_phoneController.text.isNotEmpty) {
      _bloc.add(
          CustomerInformationListSearchEvent(phone: _phoneController.text));
    } else if (_addressController.text.isNotEmpty) {
      _bloc.add(
          CustomerInformationListSearchEvent(address: _addressController.text));
    }
    _filterUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerInformationListBloc,
        CustomerInformationListState>(builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, CustomerInformationListState state) {
    if (state is CustomerInformationListLoadedState) {
      _filterUsers();
    }
  }

  Widget _builder(BuildContext context, CustomerInformationListState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Thông tin khách hàng",
        isBackNavigation: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(CustomerInformationListStartEvent());
        },
        child: Column(
          children: [
            _buildStaffInfo(),
            _buildTextField(
              placeHolder: "Họ tên",
              controller: _nameController,
              icon: Icons.people,
            ),
            _buildTextFieldPhone(
              placeHolder: "Số điện thoại",
              controller: _phoneController,
              icon: Icons.phone,
              inputType: TextInputType.phone,
              maxLength: 10,
            ),
            _buildTextFieldAddress(
              placeHolder: "Địa chỉ",
              controller: _addressController,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 150.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: ColorUtil.bangladeshGreen,
                  ),
                  child: TextButton(
                    onPressed: _onEditInfo,
                    child: const Text(
                      "Tìm kiếm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Divider(
                  color: Color(0xFFD6D6D6),
                  thickness: 2,
                  height: 30,
                ),
              ),
            ),
            _tableAction(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return _itemBuilder(context, index);
                },
              ),
            ),
            _buildfInfo(),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final UserProfile item = _filteredUsers[index];

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40.0),
          1: FixedColumnWidth(90.0),
          2: FixedColumnWidth(95.0),
          3: FixedColumnWidth(95.0),
        },
        border: TableBorder.all(color: const Color.fromRGBO(4, 107, 80, 1)),
        children: [
          TableRow(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            children: [
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${item.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        Clipboard.setData(
                                ClipboardData(text: "${item.username}"))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("copied to clipboard")));
                        });
                      },
                      child: Text(
                        "${item.username}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: "${item.phone}"))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("copied to clipboard")));
                        });
                      },
                      child: Text(
                        "${item.phone}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    // child: Text(
                    //   "${item.phone}",
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     color: Color(0xFF006A4E),
                    //   ),
                    // ),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () async {
                        Clipboard.setData(
                                ClipboardData(text: "${item.address}"))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("copied to clipboard")));
                        });
                      },
                      child: Text(
                        "${item.address}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    // child: Text(
                    //   "${item.address}",
                    //   style: const TextStyle(
                    //     fontSize: 13,
                    //     color: Color(0xFF006A4E),
                    //   ),
                    // ),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        int? seclt = _filteredUsers[index].id;
                        String? phonee = _filteredUsers[index].phone;
                        Navigator.pushNamed(context, Routes.histoyridCScreen,
                            arguments: {'id': seclt, 'phone': phonee});
                      },
                      child: const Text(
                        "Xem Chi tiết",
                        style: TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF006A4E),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildSeparator(BuildContext context, int index) {
  //   return const SizedBox(height: 12);
  // }

  Widget _buildStaffInfo() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.width * 0.01,
        child: Row(
            //height: 300,

            ),
      ),
    );
  }

  Widget _buildfInfo() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.width * 0.185,
        child: Row(),
      ),
    );
  }

  Widget _tableAction() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40.0),
        1: FixedColumnWidth(90.0),
        2: FixedColumnWidth(95.0),
        3: FixedColumnWidth(95.0),
      },
      border: TableBorder.symmetric(
        inside:
            const BorderSide(width: 1, color: Color.fromRGBO(4, 107, 80, 1)),
        //outside: const BorderSide(width: 1),
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorUtil.bangladeshGreen),
            children: const [
              TableCell(
                  child: Align(
                alignment: Alignment.center,
                child: Text("STT", style: TextStyle(color: ColorUtil.white)),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.center,
                child: Text("Họ tên", style: TextStyle(color: ColorUtil.white)),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.center,
                child: Text("Số điện thoại",
                    style: TextStyle(color: ColorUtil.white)),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.center,
                child:
                    Text("Địa chỉ", style: TextStyle(color: ColorUtil.white)),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.center,
                child:
                    Text("Lịch sử", style: TextStyle(color: ColorUtil.white)),
              )),
            ]),
      ],
    );
  }

  Widget _buildTextField({
    required String placeHolder,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    required IconData icon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: placeHolder,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldPhone({
    required String placeHolder,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    required IconData icon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: placeHolder,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldAddress({
    required String placeHolder,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    required IconData icon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: placeHolder,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
