import 'package:flutter/material.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/box_shadow_widget.dart';
import 'package:socbay/widgets/header_card_widget.dart';

class KtvSliderWidget extends StatelessWidget {
  final List<UserModel> ktvList;

  const KtvSliderWidget({super.key, required this.ktvList});

  static const List<String> _dates = [
    "CN, 26/07",
    "T2, 27/07",
    "T3, 28/07",
    "T4, 29/07",
  ];
  static const List<String> _times = [
    "08:00 - 11:00",
    "13:30 - 16:30",
    "09:00 - 12:00",
    "14:00 - 17:00",
  ];
  static const List<String> _prices = ["261k", "250k", "270k", "280k"];
  static const List<String> _origPrices = ["276k", "290k", "300k", "310k"];

  @override
  Widget build(BuildContext context) {
    final displayList = ktvList.isNotEmpty ? ktvList : [];

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
    final ageText = ktv.birthday != null && ktv.birthday!.isNotEmpty
        ? _calculateAge(ktv.birthday)
        : (35 + (index * 7) % 15).toString();

    final dateText = _dates[index % _dates.length];
    final timeText = "${_times[index % _times.length]}*";
    final priceText = _prices[index % _prices.length];
    final origPriceText = _origPrices[index % _origPrices.length];

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
                            child: const Text(
                              '5★',
                              style: TextStyle(
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
                      // Name & Age
                      Text(
                        "$nameText, $ageText",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Time slot
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              timeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Price
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: Color(0xFF52C41A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            priceText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF52C41A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            origPriceText,
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Color(0xFFBDBDBD),
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

  static String _calculateAge(String? birthday) {
    try {
      if (birthday == null || birthday.isEmpty) return "35";
      final birthDate = DateTime.parse(birthday);
      final age = DateTime.now().year - birthDate.year;
      return age > 0 ? age.toString() : "35";
    } catch (_) {
      return "35";
    }
  }
}
