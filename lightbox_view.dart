import 'package:flutter/material.dart';

/// An enumeration representing the display
/// of the thumbnails pane of a LightboxView.
///
/// The placement determines if and where the thumbnails pane is placed.
/// - [LightboxViewThumbnailPlacement.hidden]: Thumbnails pane is hidden.
/// - [LightboxViewThumbnailPlacement.top]:
///     Thumbnails pane is placed above the large image.
/// - [LightboxViewThumbnailPlacement.bottom]:
///     Thumbnails pane is placed below the large image.
///
/// This enum is used in the [LightboxView] class to specify the
/// placement of the thumbnail pane.
enum LightboxViewThumbnailPlacement { hidden, top, bottom }

/// A widget for displaying images in a lightbox view with a toggleable
/// thumbnail navigation pane.
///
/// The [LightboxView] allows you to show a single image in an overlay with the
/// option to navigate through thumbnails below. You can customize the appearance
/// and behavior of the lightbox, including thumbnail pane visibility and
/// placement, the thumbnail size, border width, and background color.
///
/// ## Example usage with thumbnails shown in the bottom:
///
/// ```dart
/// LightboxView(
///   imageUrls: myImageUrls,
///   thumbnailPlacement: LightboxViewThumbnailPlacement.bottom,
///   thumbnailUrls: myThumbnailUrls,
/// )
/// ```
class LightboxView extends StatelessWidget {
  /// List of urls to images, where the chosen index is the one being displayed.
  final List<String> imageUrls;

  /// Color of the overlay background.
  final Color overlayBackgroundColor;
  OverlayEntry? overlayEntry;

  /// Parameters for displaying a row of thumbnails.
  final LightboxViewThumbnailPlacement thumbnailPlacement;
  final List<String> thumbnailUrls;
  final double thumbnailSize;
  final double thumbnailBorderWidth;
  final Color thumbnailBorderColor;
  final List<GlobalKey> _thumbKeys;

  /// Creates a [LightboxView].
  ///
  /// The [imageUrls] parameter is required and should contain the list of URLs
  /// for the main images to be displayed in the lightbox.
  LightboxView({
    Key? key,
    required this.imageUrls,
    this.overlayBackgroundColor = Colors.black87,
    this.thumbnailPlacement = LightboxViewThumbnailPlacement.hidden,
    List<String>? thumbnailUrls,
    this.thumbnailSize = 60,
    this.thumbnailBorderWidth = 4.0,
    this.thumbnailBorderColor = Colors.redAccent,
  })  : thumbnailUrls = thumbnailUrls ?? [],
        _thumbKeys =
            List.generate(thumbnailUrls!.length, (index) => GlobalKey()),
        super(key: key);

  /// Creates the thumbnail list that can be used to navigate the list of images.
  List<Widget> thumbnails(BuildContext context, int tagIndex) {
    return List.generate(
      thumbnailUrls.length,
      (index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            showOverlay(context, index);
          },
          child: Container(
            height: thumbnailSize,
            width: thumbnailSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: index == tagIndex
                    ? thumbnailBorderColor
                    : Colors.transparent,
                width: thumbnailBorderWidth,
              ),
            ),
            child: Image.asset(
              thumbnailUrls[index],
              key: _thumbKeys[index],
              width: thumbnailSize,
              height: thumbnailSize,
            ),
          ),
        ),
      ),
    );
  }

  /// Selects what widgets are displayed depending on thumbnail placement.
  List<Widget> lightboxWidgets(BuildContext context, int tagIndex) {
    List<Widget> items = [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(imageUrls[tagIndex]),
        ),
      ),
    ];
    if (thumbnailPlacement != LightboxViewThumbnailPlacement.hidden) {
      assert(thumbnailUrls.isNotEmpty, "Must provide a non-empty list.");
      Widget thumbnailPane = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: thumbnails(context, tagIndex),
        ),
      );
      if (thumbnailPlacement == LightboxViewThumbnailPlacement.bottom) {
        items.add(thumbnailPane);
      } else if (thumbnailPlacement == LightboxViewThumbnailPlacement.top) {
        items.insert(0, thumbnailPane);
      }
    }
    return items;
  }

  /// Displays the overlay with the selected image and thumbnails.
  void showOverlay(BuildContext context, int tagIndex) {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onHorizontalDragEnd: (d) {
            if (d.primaryVelocity! > 0 && tagIndex > 0) {
              showOverlay(context, tagIndex - 1);
              scrollThumbnails(tagIndex);
            } else if (d.primaryVelocity! < 0 &&
                tagIndex < imageUrls.length - 1) {
              showOverlay(context, tagIndex + 1);
              scrollThumbnails(tagIndex);
            }
          },
          onTap: () {
            if (overlayEntry != null) {
              overlayEntry!.remove();
              overlayEntry = null;
            }
          },
          child: Container(
              color: overlayBackgroundColor,
              alignment: Alignment.center,
              child: Column(
                children: lightboxWidgets(context, tagIndex),
              )),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
    scrollThumbnails(tagIndex);
  }

  /// Makes sure that the current image is scrolled into view.
  void scrollThumbnails(int tagIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_thumbKeys[tagIndex].currentContext != null) {
        Scrollable.ensureVisible(_thumbKeys[tagIndex].currentContext!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
