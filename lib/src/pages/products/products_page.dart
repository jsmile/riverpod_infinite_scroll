import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/src/models/product.dart';
import 'package:riverpod_infinite_scroll/src/pages/product/product_page.dart';
import 'package:riverpod_infinite_scroll/src/repositories/product_repository.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  // page 변화 시 사용
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchProducts(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, Product>.separated(
          pagingController: _pagingController,
          separatorBuilder: (context, index) => const Divider(),
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, product, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductPage(id: product.id),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const SizedBox(width: 20.0),
                    CircleAvatar(
                      child: Text(product.id.toString()),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(product.title),
                        subtitle: Text(product.brand),
                      ),
                    ),
                  ],
                ),
              );
            },
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 50.0, horizontal: 30.0),
                child: Column(
                  children: [
                    const Text(
                      'Something went wrong!',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      '${_pagingController.error}',
                      style: const TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    OutlinedButton(
                      onPressed: () => _pagingController.refresh(),
                      child: const Text(
                        'Try again',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (context) => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No more products !',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchProducts(int pageKey) async {
    try {
      final newProducts =
          await ref.read(productRepositoryProvider).getProducts(pageKey);
      final isLastPage = newProducts.length < limit;
      if (isLastPage) {
        // 마지막 페이지로 추가함.
        _pagingController.appendLastPage(newProducts);
      } else {
        // 마지막 페이지가 아니면 다음 페이지로 추가함.
        final nextPageKey = pageKey + 1; // page 번호를 이용하는 경우
        // final nextPageKey = pageKey + newProducts.length;  // item 갯수를 이용하는 경우
        _pagingController.appendPage(newProducts, nextPageKey);
      }
    } catch (err) {
      _pagingController.error = err;
    }
  }
}
