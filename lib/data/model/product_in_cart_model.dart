class Product {
  const Product(
    this.productId,
    this.productName,
    this.price,
    this.subTotal,
    this.qty,
    this.weight,
    this.subWeight,
  );

  final String productId;
  final String productName;
  final int price;
  final int subTotal;
  final int qty;
  final int weight;
  final int subWeight;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return productId;
      case 1:
        return productName;
      case 2:
        return price.toString();
      case 3:
        return weight.toString();
      case 4:
        return qty.toString();
      case 5:
        return subTotal.toString();
      case 6:
        return subWeight.toString();
    }
    return '';
  }
}
