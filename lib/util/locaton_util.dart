import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ltl;
import 'package:location/location.dart';
import 'package:roadanomalies_root/util/network_util.dart';

class LocationUtil {
  static Future<String> getCurrentLocationName() async {
    var cur = await Location().getLocation();

    return await NetworkUtil.reverseGeoCode(
        LatLng(cur.latitude!, cur.longitude!),short: true);
  }

  static double getDistance(LatLng p1, LatLng p2) {
    const ltl.Distance distance = ltl.Distance();

    return distance(ltl.LatLng(p1.latitude, p1.longitude),
        ltl.LatLng(p2.latitude, p2.longitude));
  }
}
