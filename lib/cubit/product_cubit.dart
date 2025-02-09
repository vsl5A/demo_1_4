import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testtwo/cubit/loaded_list_state.dart';
import 'package:testtwo/cubit/product_state.dart';
import 'package:testtwo/models/category.dart';

import '../apis/product/product_api.dart';
import '../models/product.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductState.loading());

  final _pageSize = 5;
  LoadedListState? _lastLoadedListState;
  List<Category> _categories = [];
  List<List<Product>> _chunkedProducts = [];
  List<Product> _products = [];
  Future<void> fetchProducts(
      { String? searchKeyword, bool isNeedLoadCategories = false, String selectedCategory = 'All', required int skip}) async {
    try {
      emit(ProductState.loading());

      // var productInfo = (searchKeyword == null)
      //     ? await ProductApi.fetchProducts(skip)
      //     : await ProductApi.searchProducts(
      //         keyword: searchKeyword, skip: skip);

      if (searchKeyword != null ) {
        if(selectedCategory != 'All') {
          print('check vaao thhhhhhhhhhhhhhhhhhh 1');
          final categoryProducts = await ProductApi.fetchFilterProducts( category: selectedCategory, skip: skip);
          _products = (categoryProducts['products'] as List<Product>).where((product) {
            return product.description?.toLowerCase().contains(searchKeyword.toLowerCase()) ?? false;
          }).toList();
        } else {
          print('check vaao thhhhhhhhhhhhhhhhhhh 2');
          final infoProduct = await ProductApi.searchProducts( keyword: searchKeyword, skip: skip);
          _products = infoProduct['products'];
        }

      } else if (selectedCategory != 'All') {
        print('check vaao thhhhhhhhhhhhhhhhhhh 3');
         final infoProduct = await ProductApi.fetchFilterProducts( category: selectedCategory, skip: skip);
         _products = infoProduct['products'];
      } else {

         final infoProduct = await ProductApi.fetchProducts(skip);
         _products = infoProduct['products'];
         print('check vaao thhhhhhhhhhhhhhhhhhh 4 ${_products.length}');
      }
     // List<Product> products = List<Product>.from(productInfo['products']);
      // _chunkedProducts = products.slices(_pageSize).toList();
      //
      // int totalPages = _chunkedProducts.length;

      if (isNeedLoadCategories){
        _categories = await ProductApi.fetchAllCategories();
      }

      // if (selectedCategory != 'All'){
      //   var filteredProductsInfo = await ProductApi.fetchFilterProducts(category: selectedCategory);
      //   List<Product> filteredProducts = List<Product>.from(filteredProductsInfo['products']);
      //   var commonProducts = products.toSet().intersection(filteredProducts.toSet()).toList();
      //   products = commonProducts;
      //   _chunkedProducts = products.isNotEmpty ? products.slices(_pageSize).toList() : [];
      //   totalPages = _chunkedProducts.length;
      // }

      // debugPrint(products.length.toString());
      // debugPrint(_chunkedProducts.length.toString());
      // debugPrint(page.toString());
      // debugPrint(selectedCategory);

      emit(ProductState.loadedList(
          products: _products,
          categories: _categories,
          skip : skip,
           selectedCategory: selectedCategory));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> showProductDetail(int productId) async {
    try {
      if (state is LoadedListState) {
        _lastLoadedListState = state as LoadedListState;
      }
      emit(ProductState.loading());
      var product = await ProductApi.fetchProductById(productId);
      emit(ProductState.loadedDetail(product));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  void loadLastListState() {
    if (_lastLoadedListState != null) {
      emit(_lastLoadedListState!);
      _lastLoadedListState = null;
    }
  }
}
