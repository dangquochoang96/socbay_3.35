import 'package:socbay/utils/parse_util.dart';

class WalletModel {
  final int? userId;
  final double balance;
  
  // Keep calculated fields in case they are computed/passed from API response
  final double debt;
  final double totalAdvance;
  final double totalDeposit;

  WalletModel({
    this.userId,
    this.balance = 0.0,
    this.debt = 0.0,
    this.totalAdvance = 0.0,
    this.totalDeposit = 0.0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final rawBalance = Parse.toDoubleValue(json['balance']);
    final rawDebt = Parse.toDoubleValue(json['debt']);
    final rawAdvance = Parse.toDoubleValue(json['total_advance'] ?? json['advance']);
    final rawDeposit = Parse.toDoubleValue(json['total_deposit'] ?? json['deposit']);

    return WalletModel(
      userId: Parse.toIntValue(json['user_id']) == -1 ? null : Parse.toIntValue(json['user_id']),
      balance: rawBalance == -1 ? 0.0 : rawBalance,
      debt: rawDebt == -1 ? 0.0 : rawDebt,
      totalAdvance: rawAdvance == -1 ? 0.0 : rawAdvance,
      totalDeposit: rawDeposit == -1 ? 0.0 : rawDeposit,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'balance': balance,
        'debt': debt,
        'total_advance': totalAdvance,
        'total_deposit': totalDeposit,
      };
}

class WalletTransactionModel {
  final int? id;
  final int? walletId;
  final int? userId;
  final int? type; // 0: Thu tiền từ đơn hàng, 1: Nộp tiền về công ty, 2: Công ty ứng tiền, 3: Điều chỉnh
  final double amount;
  final int? action; // 1: in (inflow), 0: out (outflow)
  final List<String>? proofImages;
  final int? referenceType; // 0: Giao dịch phát sinh từ đơn hàng, 1: Giao dịch phát sinh từ yêu cầu nộp tiền, 2: Giao dịch phát sinh từ yêu cầu ứng tiền, 3: Kế toán điều chỉnh thủ công
  final int? referenceId;
  final int? status; // 0: Đang chờ xử lý, 1: Đã xử lý, 2: Đã từ chối
  final String? note;
  final int? createdBy;
  final int? approvedBy;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;

  WalletTransactionModel({
    this.id,
    this.walletId,
    this.userId,
    this.type,
    this.amount = 0.0,
    this.action,
    this.proofImages,
    this.referenceType,
    this.referenceId,
    this.status,
    this.note,
    this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = Parse.toDoubleValue(json['amount']);
    
    List<String>? proofList;
    if (json['proof_images'] != null) {
      if (json['proof_images'] is List) {
        proofList = List<String>.from(json['proof_images']);
      } else if (json['proof_images'] is String) {
        // Handle potential double encoded JSON array or comma separated string
        try {
          proofList = List<String>.from(Parse.toStringValue(json['proof_images']).split(','));
        } catch (_) {}
      }
    } else if (json['proof_images_url'] != null) {
      proofList = List<String>.from(json['proof_images_url']);
    }

    return WalletTransactionModel(
      id: Parse.toIntValue(json['id']) == -1 ? null : Parse.toIntValue(json['id']),
      walletId: Parse.toIntValue(json['wallet_id']) == -1 ? null : Parse.toIntValue(json['wallet_id']),
      userId: Parse.toIntValue(json['user_id']) == -1 ? null : Parse.toIntValue(json['user_id']),
      type: Parse.toIntValue(json['type']) == -1 ? null : Parse.toIntValue(json['type']),
      amount: rawAmount == -1 ? 0.0 : rawAmount,
      action: Parse.toIntValue(json['action']) == -1 ? null : Parse.toIntValue(json['action']),
      proofImages: proofList,
      referenceType: Parse.toIntValue(json['reference_type']) == -1 ? null : Parse.toIntValue(json['reference_type']),
      referenceId: Parse.toIntValue(json['reference_id']) == -1 ? null : Parse.toIntValue(json['reference_id']),
      status: Parse.toIntValue(json['status']) == -1 ? null : Parse.toIntValue(json['status']),
      note: Parse.toStringValue(json['note']),
      createdBy: Parse.toIntValue(json['created_by']) == -1 ? null : Parse.toIntValue(json['created_by']),
      approvedBy: Parse.toIntValue(json['approved_by']) == -1 ? null : Parse.toIntValue(json['approved_by']),
      approvedAt: Parse.toStringValue(json['approved_at']),
      createdAt: Parse.toStringValue(json['created_at'] ?? json['createdAt']),
      updatedAt: Parse.toStringValue(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wallet_id': walletId,
        'user_id': userId,
        'type': type,
        'amount': amount,
        'action': action,
        'proof_images': proofImages,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'status': status,
        'note': note,
        'created_by': createdBy,
        'approved_by': approvedBy,
        'approved_at': approvedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
