import 'package:flutter/material.dart';

typedef LoadMoreCallback = Future<void> Function(VoidCallback done, VoidCallback cancel);

class CustomList extends StatefulWidget {
  final List<Widget> children;
  final LoadMoreCallback? onLoadMore;
  final RefreshCallback? onRefreshData;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets? padding;
  final bool isBuilder;
  final bool isSeparated;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final bool primary;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final bool reverse;

  const CustomList.separated({
    super.key,
    required this.children,
    this.onLoadMore,
    this.onRefreshData,
    required this.separatorBuilder,
    this.padding,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.scrollController,
    this.primary = true,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse = false,
  })  : isBuilder = false,
        isSeparated = true;

  const CustomList.builder({
    super.key,
    required this.children,
    this.onLoadMore,
    this.onRefreshData,
    this.padding,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.scrollController,
    this.primary = true,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse = false,
  })  : isBuilder = true,
        isSeparated = false,
        separatorBuilder = null;

  const CustomList.children({
    super.key,
    required this.children,
    this.onLoadMore,
    this.onRefreshData,
    this.padding,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.scrollController,
    this.primary = true,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse = false,
  })  : isBuilder = false,
        isSeparated = false,
        separatorBuilder = null;

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  Widget build(BuildContext context) {
    Widget listWidget;

    if (widget.isSeparated) {
      listWidget = ListView.separated(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.scrollPhysics,
        padding: widget.padding,
        reverse: widget.reverse,
        controller: widget.scrollController,
        primary: widget.scrollController != null ? false : widget.primary,
        scrollDirection: widget.scrollDirection,
        itemCount: widget.children.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: widget.separatorBuilder!,
        itemBuilder: (context, index) {
          if (index == widget.children.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return widget.children[index];
        },
      );
    } else {
      listWidget = ListView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.scrollPhysics,
        padding: widget.padding,
        reverse: widget.reverse,
        controller: widget.scrollController,
        primary: widget.scrollController != null ? false : widget.primary,
        scrollDirection: widget.scrollDirection,
        itemCount: widget.children.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.children.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return widget.children[index];
        },
      );
    }

    if (widget.onLoadMore != null) {
      listWidget = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoadingMore &&
              _hasMore &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
            _triggerLoadMore();
          }
          return false;
        },
        child: listWidget,
      );
    }

    if (widget.onRefreshData != null) {
      listWidget = RefreshIndicator(
        onRefresh: widget.onRefreshData!,
        child: listWidget,
      );
    }

    return listWidget;
  }

  void _triggerLoadMore() async {
    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore!(
      () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            _hasMore = true;
          });
        }
      },
      () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            _hasMore = false;
          });
        }
      },
    );
  }
}
