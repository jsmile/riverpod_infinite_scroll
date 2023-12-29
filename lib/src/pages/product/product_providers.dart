import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/product.dart';
import '../../repositories/product_repository.dart';

part 'product_providers.g.dart';

@riverpod
FutureOr<Product> getProduct(GetProductRef ref, int id) {
  final product = ref.watch(productRepositoryProvider).getProduct(id);
  return product;
}
