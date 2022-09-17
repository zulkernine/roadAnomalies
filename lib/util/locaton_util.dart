import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ltl;

class LocationUtil {
  static Future<String> getCurrentLocationName() async {
    return "Jadavpur,Kolkata";
  }

  static double getDistance(LatLng p1,LatLng p2) {
    const ltl.Distance distance = ltl.Distance();

    return distance(ltl.LatLng(p1.latitude, p1.longitude), ltl.LatLng(p2.latitude, p2.longitude));
  }
}
