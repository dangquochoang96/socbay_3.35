abstract class ProductScreenEvent {
  const ProductScreenEvent();
}

class ProductScreenGetProductCategoryEvent extends ProductScreenEvent {
  final int offSet;
  final bool refresh;
  ProductScreenGetProductCategoryEvent({this.offSet = 0, this.refresh = false});
}
