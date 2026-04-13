import 'dart:convert';

OrderRent orderRentFromJson(String str) => OrderRent.fromJson(json.decode(str));

String orderRentToJson(OrderRent data) => json.encode(data.toJson());

class OrderRent {
    int? id;
    String? orderId;
    String? orderDetailId;
    String? monthlyRent;
    String? rentalPeriod;
    String? deposits;
    String? amountPaid;
    String? dept;
    String? rentStatus;
    String? rentalDate;
    String? rentalEndDate;

    OrderRent({
        this.id,
        this.orderId,
        this.orderDetailId,
        this.monthlyRent,
        this.rentalPeriod,
        this.deposits,
        this.amountPaid,
        this.dept,
        this.rentStatus,
        this.rentalDate,
        this.rentalEndDate,
    });

    factory OrderRent.fromJson(Map<String, dynamic> json) => OrderRent(
        id: json["id"] as int?,
        orderId: json["order_id"] as String?,
        orderDetailId: json["order_detail_id"] as String?,
        monthlyRent: json["monthly_rent"] as String?,
        rentalPeriod: json["rental_period"] as String?,
        deposits: json["deposits"] as String?,
        amountPaid: json["amount_paid"] as String?,
        dept: json["dept"] as String?,
        rentStatus: json["rent_status"] as String?,
        rentalDate: json["rental_date"] as String?,
        rentalEndDate: json["rental_end_date"] as String?
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "order_detail_id": orderDetailId,
        "monthly_rent": monthlyRent,
        "rental_period": rentalPeriod,
        "deposits": deposits,
        "amount_paid": amountPaid,
        "dept": dept,
        "rent_status": rentStatus,
        "rental_date": rentalDate,
        "rental_end_date": rentalEndDate
    };
}