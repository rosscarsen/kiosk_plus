import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../config.dart';

class CarouselOverlay extends StatefulWidget {
  final VoidCallback? onTap;

  const CarouselOverlay({super.key, this.onTap});

  @override
  State<CarouselOverlay> createState() => _CarouselOverlayState();
}

class _CarouselOverlayState extends State<CarouselOverlay> {
  final box = IsolatedHive.box(Config.kioskHiveBox);
  List<String>? carouselImages;
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final images = (await box.get(Config.carouselImages) as List?)?.cast<String>() ?? [];
    if (images.isNotEmpty) {
      setState(() {
        carouselImages = List<String>.from(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: CarouselSlider(
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            scrollDirection: Axis.vertical,
            autoPlayInterval: Duration(seconds: 8),
          ),
          items: carouselImages?.isNotEmpty ?? false
              ? carouselImages!
                    .map(
                      (item) => Center(
                        child: CachedNetworkImage(
                          imageUrl: item,
                          progressIndicatorBuilder: (context, url, downloadProgress) => Image.asset(
                            'assets/defaultCarousel.png',
                            fit: BoxFit.cover,
                            width: width,
                            height: height,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/defaultCarousel.png',
                            fit: BoxFit.cover,
                            width: width,
                            height: height,
                          ),
                          fit: BoxFit.cover,
                          width: width,
                          height: height,
                        ),
                        //Image.network(item, fit: BoxFit.cover, height: height),
                      ),
                    )
                    .toList()
              : [
                  'assets/carouselImages/1.png',
                  'assets/carouselImages/2.png',
                  'assets/carouselImages/3.png',
                  'assets/carouselImages/4.png',
                ].map((e) => Image.asset(e)).toList(),
        ),
      ),
    );
  }
}
