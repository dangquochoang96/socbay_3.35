abstract class CustomerInformationListEvent {
  const CustomerInformationListEvent();
}
class CustomerInformationListStartEvent extends CustomerInformationListEvent{}

class CustomerInformationListSearchEvent extends CustomerInformationListEvent {
  final String? name;
  final String? phone;
  final String? address; // Cập nhật tên tham số

  CustomerInformationListSearchEvent({
    this.name,
    this.phone,
    this.address,
  });

  List<Object?> get props => [name, phone, address];
}

