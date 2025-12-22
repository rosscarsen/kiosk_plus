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
    final raw = await box.get(Config.carouselImages);
    final List<String> images = raw is List ? raw.whereType<String>().toList() : [];
    if (images.isNotEmpty) {
      setState(() {
        carouselImages = List<String>.from(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            scrollDirection: Axis.vertical,
            autoPlayInterval: Duration(seconds: 8),
          ),
          items: (carouselImages?.isNotEmpty ?? false)
              ? carouselImages!.map((item) {
                  return SizedBox.expand(
                    child: CachedNetworkImage(
                      imageUrl: item,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset('assets/defaultCarousel.png', fit: BoxFit.cover),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/defaultCarousel.png', fit: BoxFit.cover),
                    ),
                  );
                }).toList()
              : [
                  'assets/carouselImages/1.png',
                  'assets/carouselImages/2.png',
                  'assets/carouselImages/3.png',
                  'assets/carouselImages/4.png',
                ].map((e) => SizedBox.expand(child: Image.asset(e, fit: BoxFit.cover))).toList(),
        ),
      ),
    );
  }
}
