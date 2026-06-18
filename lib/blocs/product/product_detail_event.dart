abstract class ProductDetailScreenEvent {
  const ProductDetailScreenEvent();
}

class ProductDetailScreenStartedEvent extends ProductDetailScreenEvent {}

class ProductDetailScreenLikeProductEvent extends ProductDetailScreenEvent {
  final bool isLike;
  const ProductDetailScreenLikeProductEvent(this.isLike);
}
