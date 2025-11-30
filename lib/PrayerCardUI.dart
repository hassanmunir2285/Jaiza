import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:async';

class PrayerCardScreen extends StatelessWidget {
  const PrayerCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7BC6CC), Color(0xFFBE93C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(child: PrayerCardUI()),
    );
  }
}

class PrayerCardUI extends StatefulWidget {
  const PrayerCardUI({super.key});

  @override
  State<PrayerCardUI> createState() => _PrayerCardUIState();
}

class _PrayerCardUIState extends State<PrayerCardUI> {
  // Location data
  double? _latitude;
  double? _longitude;
  String _location = "Loading location...";

  // Prayer times - Map for easy access (stored as local DateTime)
  Map<String, DateTime?> _prayerTimes = {
    'Fajr': null,
    'Zuhr': null,
    'Asr': null,
    'Maghrib': null,
    'Isha': null,
  };

  // Current prayer info
  String _currentPrayerName = "Loading...";
  DateTime? _currentPrayerTime;
  String _remainingTime = "Loading...";

  // Time and date
  String _currentTime = "00:00 AM";
  String _hijriDate = "Loading...";

  // Loading state
  bool _isLoading = true;
  bool _isRefreshing = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCurrentTime();
        _updateCurrentPrayer();
        _updateRemainingTime();
      }
    });
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    setState(() {
      _currentTime = "$displayHour:$minute $period";
    });
  }

  Future<void> _initializeData() async {
    await _getLocationAndPrayerTimes();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _getLocationAndPrayerTimes();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _getLocationAndPrayerTimes() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permission denied";
          _isLoading = false;
        });
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get location name
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _latitude!,
          _longitude!,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          _location = [
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(", ");
        }
      } catch (e) {
        _location =
            "Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}";
      }

      // Calculate prayer times
      _calculatePrayerTimes();

      // Hijri date
      _updateHijriDate();

      // Update current prayer
      _updateCurrentPrayer();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _location = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _calculatePrayerTimes() {
    if (_latitude == null || _longitude == null) return;

    final coordinates = Coordinates(_latitude!, _longitude!);

    // Use Muslim World League calculation method
    final params = CalculationParameters(
      method: CalculationMethod.muslimWorldLeague,
      fajrAngle: 18.0,
      ishaAngle: 17.0,
    );
    params.madhab = Madhab.hanafi;

    // Get today's date in local timezone
    final now = DateTime.now();

    // Calculate prayer times
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      calculationParameters: params,
      date: now,
      precision: true,
    );

    // Convert UTC times to local device time
    final localOffset = now.timeZoneOffset;

    DateTime _convertToLocal(DateTime utcTime) {
      return utcTime.add(localOffset);
    }

    setState(() {
      _prayerTimes['Fajr'] = _convertToLocal(prayerTimes.fajr);
      _prayerTimes['Zuhr'] = _convertToLocal(prayerTimes.dhuhr);
      _prayerTimes['Asr'] = _convertToLocal(prayerTimes.asr);
      _prayerTimes['Maghrib'] = _convertToLocal(prayerTimes.maghrib);
      _prayerTimes['Isha'] = _convertToLocal(prayerTimes.isha);
    });

    // Debug: Print times to verify
    print('=== Prayer Times for ${now.toLocal()} ===');
    print('Fajr: ${_prayerTimes['Fajr']}');
    print('Zuhr: ${_prayerTimes['Zuhr']}');
    print('Asr: ${_prayerTimes['Asr']}');
    print('Maghrib: ${_prayerTimes['Maghrib']}');
    print('Isha: ${_prayerTimes['Isha']}');
  }

  void _updateHijriDate() {
    try {
      final hijriDate = HijriCalendar.now();
      final monthNames = [
        'Muharram',
        'Safar',
        'Rabi\' al-awwal',
        'Rabi\' al-thani',
        'Jumada al-awwal',
        'Jumada al-thani',
        'Rajab',
        'Sha\'ban',
        'Ramadan',
        'Shawwal',
        'Dhu al-Qi\'dah',
        'Dhu al-Hijjah',
      ];

      setState(() {
        _hijriDate =
            "${hijriDate.hDay}, ${monthNames[hijriDate.hMonth - 1]}, ${hijriDate.hYear}";
      });
    } catch (e) {
      setState(() {
        _hijriDate = "Error getting Hijri date";
      });
    }
  }

  // Determine which prayer is currently happening
  void _updateCurrentPrayer() {
    final now = DateTime.now();
    List<String> prayerOrder = ['Fajr', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];

    String? currentPrayer;

    // Check which prayer is currently happening
    for (int i = 0; i < prayerOrder.length; i++) {
      String prayer = prayerOrder[i];
      String nextPrayer = i < prayerOrder.length - 1
          ? prayerOrder[i + 1]
          : 'Fajr';

      DateTime? prayerTime = _prayerTimes[prayer];
      DateTime? nextPrayerTime = i < prayerOrder.length - 1
          ? _prayerTimes[nextPrayer]
          : null; // Fajr is tomorrow

      if (prayerTime != null) {
        // Check if current time is between this prayer and next prayer
        if (nextPrayerTime != null &&
            now.isAfter(prayerTime) &&
            now.isBefore(nextPrayerTime)) {
          currentPrayer = prayer;
          _currentPrayerTime = prayerTime;
          break;
        } else if (nextPrayerTime == null && now.isAfter(prayerTime)) {
          // After Isha, current prayer is Isha
          currentPrayer = prayer;
          _currentPrayerTime = prayerTime;
          break;
        }
      }
    }

    // If no current prayer found (before Fajr), show Fajr as current
    if (currentPrayer == null) {
      currentPrayer = 'Fajr';
      _currentPrayerTime = _prayerTimes['Fajr'];
    }

    setState(() {
      _currentPrayerName = currentPrayer ?? 'Fajr';
    });

    _updateRemainingTime();
  }

  void _updateRemainingTime() {
    if (_currentPrayerTime == null) return;

    final now = DateTime.now();
    final difference = _currentPrayerTime!.difference(now);

    if (difference.isNegative) {
      setState(() {
        _remainingTime = "Time passed";
      });
      return;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    setState(() {
      if (hours > 0) {
        _remainingTime = "${hours}h ${minutes}m";
      } else {
        _remainingTime = "${minutes}m ${seconds}s";
      }
    });
  }

  String _formatPrayerTime(DateTime? time) {
    if (time == null) return "--:--";
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "$displayHour:$minute $period";
  }

  // Get other prayers (excluding current prayer)
  List<Map<String, dynamic>> _getOtherPrayers() {
    List<String> prayerOrder = ['Fajr', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];
    List<Map<String, dynamic>> otherPrayers = [];

    for (String prayer in prayerOrder) {
      if (prayer != _currentPrayerName && _prayerTimes[prayer] != null) {
        otherPrayers.add({'name': prayer, 'time': _prayerTimes[prayer]});
      }
    }

    return otherPrayers;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Current Prayer Info with Refresh Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Current Prayer Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Prayer",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentPrayerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatPrayerTime(_currentPrayerTime),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right: Current Time & Remaining Time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _currentTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Remaining",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _remainingTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Refresh Button
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: _isRefreshing ? null : _refreshData,
                            icon: _isRefreshing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Divider
                    const Divider(color: Colors.white30, height: 1),
                    const SizedBox(height: 12),
                    // Prayer Times Row (All 4 in single row)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _getOtherPrayers().length,
                        itemBuilder: (context, index) {
                          final prayer = _getOtherPrayers()[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: PrayerTimeItem(
                              name: prayer['name'] as String,
                              time: _formatPrayerTime(
                                prayer['time'] as DateTime?,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Location and Hijri Date
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hijriDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class PrayerTimeItem extends StatelessWidget {
  final String name;
  final String time;

  const PrayerTimeItem({super.key, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
