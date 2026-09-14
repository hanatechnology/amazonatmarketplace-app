import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/address_location.dart';

/// What the sheet is saying about the point under the pin.
enum _PinState {
  /// The map is being dragged. Nothing under the pin is settled.
  moving,

  /// Camera is idle and the geocoder is being asked.
  resolving,

  /// A street address came back.
  resolved,

  /// The geocoder returned nothing, or failed. The coordinates still stand.
  noAddress,
}

/// Why the recenter button could not move the camera.
enum _LocationBlock { servicesOff, permissionDenied }

/// Pins the delivery point for an address.
///
/// `POST /addresses` requires `location{lat,lng,address}`. The contract has no
/// geocoding endpoint, so the readable half is read off the **device** geocoder
/// (`CLGeocoder` / Android `Geocoder`) in the language the app is running in —
/// no API key, and it degrades to the raw coordinate pair rather than failing
/// the flow.
///
/// The pin is fixed to the centre of the viewport and the map moves under it: a
/// draggable marker is fiddly at street zoom on a phone. The pin's *tip* is the
/// coordinate, so the shadow and the accuracy disc centre on the tip, never on
/// the middle of the pin.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  /// Opens the picker and returns the chosen point, or null if dismissed.
  static Future<AddressLocation?> show({AddressLocation? initial}) async {
    return Get.to<AddressLocation>(
      () => const LocationPickerPage(),
      arguments: {'initial': initial},
    );
  }

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage>
    with SingleTickerProviderStateMixin {
  static const double _pinnedZoom = 16;

  /// How long after the camera stops before the geocoder is asked. Short enough
  /// to feel immediate, long enough that a flick across town is one lookup and
  /// not thirty.
  static const Duration _geocodeDebounce = Duration(milliseconds: 400);

  /// Google's tiles ship light in both themes. Under the dark palette that
  /// leaves white map, dark chrome — so the map is restyled to the app's own
  /// ink and olive rather than left as the one light surface in a dark app.
  static const String _darkMapStyle = '''
[
 {"elementType":"geometry","stylers":[{"color":"#171e17"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#8f9a8a"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#0e1310"}]},
 {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#2a332a"}]},
 {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#7f8a7a"}]},
 {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f2a1b"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#28312a"}]},
 {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9aa595"}]},
 {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#222b23"}]},
 {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#33402f"}]},
 {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#1d251d"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#101e1c"}]},
 {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#54655f"}]}
]
''';

  late final AddressLocation _initial;
  late final LatLng _target;

  GoogleMapController? _map;

  /// The device's own geocoder — `CLGeocoder` on iOS, `Geocoder` on Android.
  final Geocoding _geocoder = Geocoding();

  /// Drives the pin lift. Forward while the camera moves, reversed on idle —
  /// the reverse leg is longer and overshoots so the pin lands rather than
  /// snaps.
  late final AnimationController _lift;
  late final Animation<double> _liftCurve;

  /// The live coordinate under the pin. A [ValueNotifier] rather than state so
  /// a camera frame repaints one label, not the map.
  late final ValueNotifier<LatLng> _coordinate;

  Timer? _debounce;

  /// Bumped on every camera move so a late geocoder reply for a point the
  /// customer has already left is dropped instead of overwriting the new one.
  int _lookupToken = 0;

  _PinState _state = _PinState.resolving;
  String? _addressLine;
  String? _localityLine;
  String? _city;
  _LocationBlock? _block;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _initial = (args is Map ? args['initial'] as AddressLocation? : null) ??
        AddressLocation.tripoli;
    _target = LatLng(_initial.lat, _initial.lng);
    _coordinate = ValueNotifier<LatLng>(_target);

    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _liftCurve = CurvedAnimation(
      parent: _lift,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutBack.flipped,
    );

    // The point the picker opened on is a real point: read it now rather than
    // making the customer nudge the map to see where they are.
    _resolve(_target);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _lift.dispose();
    _coordinate.dispose();
    _map?.dispose();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────
  void _onCameraMoveStarted() {
    _debounce?.cancel();
    _lookupToken++;
    _lift.forward();
    if (_state != _PinState.moving) {
      setState(() {
        _state = _PinState.moving;
        _block = null;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _coordinate.value = position.target;
  }

  void _onCameraIdle() {
    _lift.reverse();
    HapticFeedback.selectionClick();
    _debounce?.cancel();
    _debounce = Timer(_geocodeDebounce, () => _resolve(_coordinate.value));
  }

  // ── Geocoding ─────────────────────────────────────────────
  Future<void> _resolve(LatLng point) async {
    final token = ++_lookupToken;
    if (mounted && _state != _PinState.resolving) {
      setState(() => _state = _PinState.resolving);
    }

    List<Placemark> places;
    try {
      places = await _geocoder.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
        locale: Get.locale,
      );
    } catch (_) {
      // No network, no geocoder on the device, nothing at the coordinate — all
      // the same outcome to a customer: keep the point, drop the label.
      places = const [];
    }

    if (!mounted || token != _lookupToken) return;

    final place = places.isEmpty ? null : places.first;
    final street = _streetOf(place);
    final locality = _localityOf(place);

    setState(() {
      _addressLine = street;
      _localityLine = locality;
      _city = place?.locality?.trim().isNotEmpty == true
          ? place!.locality!.trim()
          : null;
      _state = street == null && locality == null
          ? _PinState.noAddress
          : _PinState.resolved;
    });
  }

  /// The line the customer recognises: a street, or the named place standing on
  /// it. Falls back through the fields platforms disagree about.
  static String? _streetOf(Placemark? place) {
    if (place == null) return null;
    for (final candidate in [place.street, place.thoroughfare, place.name]) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty && value != place.locality) {
        return value;
      }
    }
    return null;
  }

  /// District, city, country — whatever of it exists, in that order.
  static String? _localityOf(Placemark? place) {
    if (place == null) return null;
    final parts = <String>[];
    for (final candidate in [
      place.subLocality,
      place.locality,
      place.country,
    ]) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty && !parts.contains(value)) {
        parts.add(value);
      }
    }
    if (parts.isEmpty) return null;
    return parts.join(Get.locale?.languageCode == 'ar' ? '، ' : ', ');
  }

  /// What travels back as `location.address`. Empty when the geocoder had
  /// nothing — the caller falls back to what the customer typed on the form.
  String get _addressForApi {
    final parts = [_addressLine, _localityLine]
        .whereType<String>()
        .where((part) => part.isNotEmpty);
    return parts.join(Get.locale?.languageCode == 'ar' ? '، ' : ', ');
  }

  // ── Recenter ──────────────────────────────────────────────
  Future<void> _recenter() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _block = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _block = _LocationBlock.servicesOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _block = _LocationBlock.permissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;

      // Animated, not cut: a jump loses the customer's sense of where the map
      // went.
      await _map?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          _pinnedZoom,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _block = _LocationBlock.servicesOff);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _openSettings() async {
    if (_block == _LocationBlock.servicesOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  // ── Confirm ───────────────────────────────────────────────
  bool get _canConfirm =>
      _state == _PinState.resolved || _state == _PinState.noAddress;

  void _confirm() {
    if (!_canConfirm) return;
    final point = _coordinate.value;
    Get.back(
      result: AddressLocation(
        lat: point.latitude,
        lng: point.longitude,
        address: _addressForApi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // The status bar sits on the map, so its icons follow the map's own
    // brightness rather than the app bar that is not there.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: palette.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _target,
                  zoom: _pinnedZoom,
                ),
                style: palette.isDark ? _darkMapStyle : null,
                onMapCreated: (controller) => _map = controller,
                onCameraMoveStarted: _onCameraMoveStarted,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            _CentrePin(lift: _liftCurve),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(MarketplaceSpacing.md),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: Icons.chevron_left_rounded,
                      semanticLabel: LocaleKeys.back.tr,
                      onTap: Get.back,
                    ),
                    if (_city != null) ...[
                      const SizedBox(width: MarketplaceSpacing.sm + 2),
                      _CityPill(city: _city!),
                    ],
                  ],
                ),
              ),
            ),
            _Sheet(
              state: _state,
              addressLine: _addressLine,
              localityLine: _localityLine,
              coordinate: _coordinate,
              block: _block,
              isLocating: _isLocating,
              canConfirm: _canConfirm,
              onRecenter: _recenter,
              onOpenSettings: _openSettings,
              onConfirm: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

/// The fixed pin, its ground shadow and the disc marking the point.
///
/// Everything here is driven off one animation: as the pin rises the shadow
/// shrinks and falls away from it, which is what reads as height, and the disc
/// fades out because nothing under a moving map is settled.
class _CentrePin extends StatelessWidget {
  const _CentrePin({required this.lift});

  final Animation<double> lift;

  static const double _pinHeight = 58;
  static const double _liftDistance = 16;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: lift,
          builder: (context, _) {
            final t = lift.value.clamp(0.0, 1.0);
            return SizedBox(
              height: _pinHeight * 2,
              child: Stack(
                alignment: Alignment.center,
                // The lift moves the pin to a negative offset; the default
                // hard-edge clip would cut its head off mid-rise.
                clipBehavior: Clip.none,
                children: [
                  // Centred on the tip of the pin, which is the coordinate.
                  Positioned(
                    top: _pinHeight - 34,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Transform.scale(
                        scale: 0.92 + (0.08 * (1 - t)),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette.brand.withValues(alpha: 0.10),
                            border: Border.all(
                              color: palette.brand.withValues(alpha: 0.34),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: _pinHeight + 2 + (12 * t),
                    child: Container(
                      width: 19 - (7 * t),
                      height: 5 - (1.5 * t),
                      decoration: BoxDecoration(
                        color:
                            Colors.black.withValues(alpha: 0.20 - (0.09 * t)),
                        borderRadius: BorderRadius.circular(99),
                        // Blurred rather than a hard ellipse: at 19 pt a crisp
                        // edge reads as a UI element sitting on the map, not as
                        // the pin's shadow falling on it.
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.16 - (0.07 * t)),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -(_liftDistance * t),
                    child: Icon(
                      Icons.location_on,
                      size: _pinHeight,
                      color: palette.brand,
                      shadows: const [
                        Shadow(color: Color(0x59000000), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The bottom sheet: what the point is, where it is, and the way out.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.state,
    required this.addressLine,
    required this.localityLine,
    required this.coordinate,
    required this.block,
    required this.isLocating,
    required this.canConfirm,
    required this.onRecenter,
    required this.onOpenSettings,
    required this.onConfirm,
  });

  final _PinState state;
  final String? addressLine;
  final String? localityLine;
  final ValueNotifier<LatLng> coordinate;
  final _LocationBlock? block;
  final bool isLocating;
  final bool canConfirm;
  final VoidCallback onRecenter;
  final VoidCallback onOpenSettings;
  final VoidCallback onConfirm;

  /// The address block is three states deep. A fixed height keeps the sheet
  /// still while they swap, so the confirm button never moves under a thumb.
  static const double _slotHeight = 54;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sits on the map rather than in the sheet: a thumb reaches it
          // without covering the pin.
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              0,
              0,
              MarketplaceSpacing.md,
              MarketplaceSpacing.sm + 2,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _CircleButton(
                icon: Icons.my_location_rounded,
                semanticLabel: LocaleKeys.myLocation.tr,
                onTap: onRecenter,
                isBusy: isLocating,
                isMuted: block != null,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              border: Border(top: BorderSide(color: palette.hairline)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: palette.hairline,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: _slotHeight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.07),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _AddressBlock(
                          key: ValueKey(state),
                          state: state,
                          addressLine: addressLine,
                          localityLine: localityLine,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: palette.hairline),
                    const SizedBox(height: 12),
                    _CoordinateRow(coordinate: coordinate, state: state),
                    if (block != null) ...[
                      const SizedBox(height: 12),
                      _BlockNotice(
                          block: block!, onOpenSettings: onOpenSettings),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        LocaleKeys.mapPinHint.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11,
                          height: 1.65,
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _ConfirmButton(isEnabled: canConfirm, onTap: onConfirm),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Leading tile plus two lines, one variant per [_PinState].
class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    super.key,
    required this.state,
    required this.addressLine,
    required this.localityLine,
  });

  final _PinState state;
  final String? addressLine;
  final String? localityLine;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (title, subtitle, isMuted) = switch (state) {
      _PinState.moving => (
          LocaleKeys.mapMoving.tr,
          LocaleKeys.mapMovingHint.tr,
          true,
        ),
      _PinState.resolving => (null, null, false),
      _PinState.noAddress => (
          LocaleKeys.noStreetAddress.tr,
          LocaleKeys.noStreetAddressHint.tr,
          true,
        ),
      _PinState.resolved => (
          addressLine ?? localityLine ?? '',
          addressLine == null ? null : localityLine,
          false,
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.surfaceSunken,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: state == _PinState.resolving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: palette.brand,
                    backgroundColor: palette.hairline,
                  ),
                )
              : Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: isMuted ? palette.textMuted : palette.brand,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: state == _PinState.resolving
              ? const _AddressSkeleton()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? '',
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 14.5,
                        height: 1.45,
                        color: isMuted
                            ? palette.textSecondary
                            : palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: MarketplaceTypography.rowMeta.copyWith(
                            fontSize: 11.5,
                            height: 1.6,
                            color: palette.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Two bars standing in for the address while the geocoder answers.
class _AddressSkeleton extends StatelessWidget {
  const _AddressSkeleton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget bar(double widthFactor, double height) => FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bar(0.74, 12),
          const SizedBox(height: 8),
          bar(0.52, 10),
        ],
      ),
    );
  }
}

/// The coordinate pair, and what it means right now.
///
/// A figure: Latin digits, left to right, in Arabic as much as in English.
class _CoordinateRow extends StatelessWidget {
  const _CoordinateRow({required this.coordinate, required this.state});

  final ValueNotifier<LatLng> coordinate;
  final _PinState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final label = switch (state) {
      _PinState.moving => LocaleKeys.coordinatesLive.tr,
      _PinState.resolving => LocaleKeys.resolvingAddress.tr,
      _PinState.resolved || _PinState.noAddress => LocaleKeys.coordinates.tr,
    };

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: palette.surfaceSunken,
            borderRadius: BorderRadius.circular(MarketplaceRadius.sm - 2),
          ),
          child: ValueListenableBuilder<LatLng>(
            valueListenable: coordinate,
            builder: (context, value, _) => Text(
              '${value.latitude.toStringAsFixed(5)}, '
              '${value.longitude.toStringAsFixed(5)}',
              textDirection: TextDirection.ltr,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: MarketplaceSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 10.5,
              color: palette.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Why the recenter button did nothing, and the way to fix it.
class _BlockNotice extends StatelessWidget {
  const _BlockNotice({required this.block, required this.onOpenSettings});

  final _LocationBlock block;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final foreground =
        isDark ? const Color(0xFFE7C77F) : const Color(0xFF7A5310);
    final background =
        isDark ? const Color(0xFF2A2317) : const Color(0xFFF6EEDC);

    final message = block == _LocationBlock.servicesOff
        ? LocaleKeys.locationServicesOff.tr
        : LocaleKeys.locationPermissionDenied.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MarketplaceRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: foreground),
          const SizedBox(width: 9),
          Expanded(
            child: GestureDetector(
              onTap: onOpenSettings,
              behavior: HitTestBehavior.opaque,
              child: Text.rich(
                TextSpan(
                  text: '$message ',
                  children: [
                    TextSpan(
                      text: LocaleKeys.openSettings.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  height: 1.6,
                  color: foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Disabled while the map moves or the geocoder is out: confirming mid-drag
/// saves a point the customer never looked at. "No street address" still
/// confirms — the coordinates alone are a valid answer.
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.isEnabled, required this.onTap});

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.brand,
          foregroundColor: palette.onBrand,
          disabledBackgroundColor: palette.surfaceSunken,
          disabledForegroundColor: palette.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              size: 17,
              color: isEnabled ? palette.onBrand : palette.textMuted,
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.confirmLocation.tr,
              style: MarketplaceTypography.buttonLabel.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isEnabled ? palette.onBrand : palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The city the pin is standing in, read off the geocoder.
class _CityPill extends StatelessWidget {
  const _CityPill({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 34,
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: palette.brand,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              city,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating round control over the map.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.isBusy = false,
    this.isMuted = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool isBusy;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: isBusy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.surface,
            shape: BoxShape.circle,
            border: Border.all(color: palette.hairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isBusy
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: palette.brand,
                  ),
                )
              : Icon(
                  icon,
                  size: 21,
                  color: isMuted ? palette.textMuted : palette.textPrimary,
                ),
        ),
      ),
    );
  }
}
