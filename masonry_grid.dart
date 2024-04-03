import 'package:flutter/material.dart';

/// An enumeration representing the orientation of a MasonryGrid.
///
/// The orientation determines how the main axis of the MasonryGrid is arranged.
/// - [MasonryGridOrientation.columns]: Items are arranged in columns.
/// - [MasonryGridOrientation.rows]: Items are arranged in rows.
///
/// This enum is used in the [MasonryGrid] class to specify the layout orientation.
enum MasonryGridOrientation { columns, rows }

/// A widget that arranges a list of items in a masonry grid layout.
///
/// The `MasonryGrid` allows you to specify the number of main axis elements
/// and their orientation (columns or rows) within the grid. It supports both
/// vertical and horizontal scrolling to accommodate different screen sizes.
///
/// By default, the grid arranges items in columns. You can customize the
/// alignment and cross-alignment of the columns or rows.
class MasonryGrid extends StatelessWidget {
  /// The number of main axis elements in the grid.
  final int mainAxisCount;

  /// The list of items to arrange in the grid.
  final List<Widget> items;

  /// The padding around each item in the grid.
  final EdgeInsets padding;

  /// The orientation of the main axis elements in the grid.
  final MasonryGridOrientation mainAxisOrientation;

  /// The alignment of the columns or rows in the grid.
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;

  /// Creates a `MasonryGrid` widget.
  ///
  /// The [mainAxisCount] specifies the number of elements in the main axis
  /// of the grid. The [items] represent the list of widgets to be arranged
  /// in the masonry grid. The [padding] is applied to each item, and the
  /// [mainAxisOrientation] determines whether the grid is organized in
  /// columns or rows.
  const MasonryGrid({
    Key? key,
    required this.mainAxisCount,
    required this.items,
    required this.padding,
    required this.mainAxisOrientation,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainAxisChildren = _buildMainAxisChildren();

    if (mainAxisOrientation == MasonryGridOrientation.columns) {
      return _buildColumns(mainAxisChildren);
    } else {
      return _buildRows(mainAxisChildren);
    }
  }

  /// Builds the list of main axis children based on the provided parameters.
  List<List<Widget>> _buildMainAxisChildren() {
    assert(mainAxisCount > 0);
    List<List<Widget>> mainAxisChildren = [];
    for (int j = 0; j < mainAxisCount; j++) {
      List<Widget> tmpList = [];
      for (int i = j; i < items.length; i += mainAxisCount) {
        tmpList.add(
          Padding(
            padding: padding,
            child: Container(
              child: items[i],
            ),
          ),
        );
      }
      mainAxisChildren.add(tmpList);
    }
    return mainAxisChildren;
  }

  /// Builds the grid with columns based on the provided main axis children.
  Widget _buildColumns(List<List<Widget>> mainAxisChildren) {
    final columns = List.generate(
      mainAxisCount,
      (index) => Column(
        mainAxisAlignment: columnMainAxisAlignment,
        crossAxisAlignment: columnCrossAxisAlignment,
        children: [...mainAxisChildren[index]],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: rowCrossAxisAlignment,
        children: columns.map((column) => Expanded(child: column)).toList(),
      ),
    );
  }

  /// Builds the grid with rows based on the provided main axis children.
  Widget _buildRows(List<List<Widget>> mainAxisChildren) {
    final rows = List.generate(
      mainAxisCount,
      (index) => Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: rowCrossAxisAlignment,
        children: [...mainAxisChildren[index]],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: columnMainAxisAlignment,
        crossAxisAlignment: columnCrossAxisAlignment,
        children: rows.map((row) => Expanded(child: row)).toList(),
      ),
    );
  }
}
