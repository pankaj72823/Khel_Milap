import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../theme/fonts.dart';

class AdCarousel extends StatefulWidget {
  final List<Map<String, String>> ads;

  // Constructor to pass the ads data
  AdCarousel({required this.ads});

  @override
  _AdCarouselState createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  int _currentIndex = 0;

  Widget _adCard(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: AppFonts.bodyText,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.ads.length,
          itemBuilder: (context, index, realIndex) {
            final ad = widget.ads[index];
            return _adCard(ad['title']!, ad['imagePath']!);
          },
          options:  CarouselOptions(
            height: 320,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.ads.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Colors.blueAccent
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


