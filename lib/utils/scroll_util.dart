import 'package:flutter/material.dart';

void scrollPaginationListener(
    {required ScrollController scrollController,
    required bool condition,
    required void Function() paginationFunction}) {
  if (scrollController.position.extentAfter < 300 && condition) {
    paginationFunction();
  }
}
