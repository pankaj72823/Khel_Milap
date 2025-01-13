import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';


class LiveUpdates extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // List of headlines
    final headlines = [
      'Selection for Volleyball State team will start by next week 🚀',
      'Cricket Trials in Ahmedabad ',
      'Xaviers club is looking for a new player for football team',
    ];

    // Combine headlines with a separator
    final marqueeText = headlines.join(' | ');

    return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange, // Retain the orange color
              borderRadius: BorderRadius.circular(12), // Add rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
                  blurRadius: 8,
                  offset: Offset(0, 4), // Shadow offset
                ),
              ],
              border: Border.all(
                color: Colors.white, // Border to highlight the container
                width: 2,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8), // Add inner padding
            height: 50,
            child: Row(
              children: [
                Icon(Icons.live_tv, color: Colors.white), // Live update icon
                SizedBox(width: 8), // Space between icon and text
                Expanded(
                  child: Marquee(
                    text: marqueeText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 20.0,
                    velocity: 50.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 2),
                    accelerationCurve: Curves.easeIn,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}