import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_provider.dart';
import '../models/product.dart';

part 'product_repository.g.dart';

const limit = 20; // 10 products per page

/// 상품 목록과 개별 상품을 가져오는 레포지토리
class ProductRepository {
  final Dio dio;

  ProductRepository(this.dio);

  Future<List<Product>> getProducts(int page) async {
    try {
      final Response response = await dio.get(
        '/products',
        queryParameters: {
          'limit': limit,
          'skip': (page - 1) * limit,
        },
      );

      if (response.statusCode != 200) throw 'Fail to fetch products';

      final List productList = response.data['products'];

      final products = [
        for (final product in productList) Product.fromJson(product)
      ];

      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final Response response = await dio.get('/products/$id'); // path 만으로 가능

      if (response.statusCode != 200) throw 'Fail to fetch product';

      final product = Product.fromJson(response.data);

      return product;
    } catch (e) {
      rethrow;
    }
  }
}

// provider 로 productRepository 를 노출시키기
@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.watch(dioProvider));
}
