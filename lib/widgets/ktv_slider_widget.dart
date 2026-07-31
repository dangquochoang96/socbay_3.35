import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/box_shadow_widget.dart';
import 'package:socbay/widgets/header_card_widget.dart';

class KtvSliderWidget extends StatefulWidget {
  final List<UserModel> ktvList;

  const KtvSliderWidget({super.key, required this.ktvList});

  @override
  State<KtvSliderWidget> createState() => _KtvSliderWidgetState();
}

class _KtvSliderWidgetState extends State<KtvSliderWidget> {
  final Map<int, String> _ratingMap = {};
  final Set<int> _loadingSet = {};

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  @override
  void didUpdateWidget(covariant KtvSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchRatings();
  }

  void _fetchRatings() {
    for (final ktv in widget.ktvList) {
      if (ktv.id != null &&
          !_ratingMap.containsKey(ktv.id) &&
          !_loadingSet.contains(ktv.id)) {
        _fetchRatingForStaff(ktv.id!);
      }
    }
  }

  Future<void> _fetchRatingForStaff(int staffId) async {
    _loadingSet.add(staffId);
    try {
      final url = AppConfig.instance.apiUri(
        ApiEndpoints.listOrderRatingByStaff,
        {'user_id': staffId.toString()},
      );
      final res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          json.decode(res.body),
        );
        final data = map['data'];
        if (data is List && data.isNotEmpty) {
          double totalRate = 0;
          int count = 0;
          for (var item in data) {
            if (item != null && item['rate'] != null) {
              final rateVal = double.tryParse(item['rate'].toString());
              if (rateVal != null && rateVal > 0) {
                totalRate += rateVal;
                count++;
              }
            }
          }
          if (count > 0) {
            final avgRate = totalRate / count;
            final formattedAvg = (avgRate % 1 == 0)
                ? avgRate.toInt().toString()
                : avgRate.toStringAsFixed(1);
            if (mounted) {
              setState(() {
                _ratingMap[staffId] = '$formattedAvg★';
              });
            }
          }
        }
      }
    } catch (_) {
      // Keep default on error
    } finally {
      _loadingSet.remove(staffId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = widget.ktvList.isNotEmpty ? widget.ktvList : [];

    return BoxShadowWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderCardWidget(
            text: 'Đội ngũ Kỹ thuật viên',
            isViewMore: true,
            onViewMore: () {
              Navigator.pushNamed(context, Routes.hotlineScreen);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                return _buildKtvCard(context, displayList[index], index);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildKtvCard(BuildContext context, UserModel ktv, int index) {
    final nameText = ktv.username ?? 'KTV Chuyên nghiệp';
    final phoneText = (ktv.phone != null && ktv.phone!.isNotEmpty)
        ? ktv.phone!
        : 'Chưa cập nhật';
    final addressText = (ktv.address != null && ktv.address!.isNotEmpty)
        ? ktv.address!
        : 'Chưa cập nhật';
    const workTimeText = '8h đến 20h';

    final avatarUrl = ImageUtil.getUrlFromPath(ktv.companyAvatar ?? '');

    return Container(
      width: 295,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onViewKtvInfo(context, ktv),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left column: Avatar & "Đặt ngay" Button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF52C41A),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: avatarUrl.isNotEmpty
                                ? ImageUtil.loadNetWorkImage(
                                    url: avatarUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: const Color(0xFFEEEEEE),
                                    child: const Icon(
                                      Icons.person,
                                      size: 36,
                                      color: Color(0xFFBDBDBD),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorUtil.brightYellow,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              _ratingMap[ktv.id] ?? '0★',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 82,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _onBookingKtv(context, ktv),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtil.brightYellow,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đặt ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Right column: KTV details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tên KTV
                      Text(
                        nameText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Số điện thoại
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 15,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              phoneText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Địa chỉ
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              addressText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Thời gian làm việc
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              workTimeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _onViewKtvInfo(BuildContext context, UserModel ktv) {
    Navigator.pushNamed(
      context,
      Routes.staffInfoScreen,
      arguments: {"id": ktv.id, "name": ktv.username, "staffInfo": ktv},
    );
  }

  static void _onBookingKtv(BuildContext context, UserModel ktv) {
    Navigator.pushNamed(
      context,
      Routes.serviceScreen,
      arguments: {
        "listService": HomeServiceModel.serviceList,
        "index": "0",
        "favouriteStaff": ktv,
      },
    );
  }
}
