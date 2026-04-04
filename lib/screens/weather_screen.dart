import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  final void Function(WeatherModel)? onWeatherLoaded;
  const WeatherScreen({super.key, this.onWeatherLoaded});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _service = WeatherService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  WeatherModel? _weather;
  ForecastModel? _forecast;
  bool _isLoading = false;
  String? _error;

  // ── Condition-based accent color ────────────────────────────────────────
  Color _accentColor(String? condition) {
    if (condition == null) return const Color(0xFF7C6FFF);
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sun')) return const Color(0xFFFB923C);
    if (c.contains('rain') || c.contains('drizzle')) return const Color(0xFF22D3EE);
    if (c.contains('thunder') || c.contains('storm')) return const Color(0xFFFF4D6D);
    if (c.contains('snow')) return const Color(0xFF93C5FD);
    if (c.contains('cloud')) return const Color(0xFF94A3B8);
    if (c.contains('mist') || c.contains('fog') || c.contains('haze'))
      return const Color(0xFFA78BFA);
    return const Color(0xFF7C6FFF);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;
    _startLoading();
    try {
      final w = await _service.fetchWeather(city);
      final f = await _service.fetchForecast(city);
      _setResult(w, f);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _fetchByLocation() async {
    _startLoading();
    try {
      final Position pos = await _service.getCurrentPosition();
      final w = await _service.fetchWeatherByCoords(pos.latitude, pos.longitude);
      final f = await _service.fetchForecastByCoords(pos.latitude, pos.longitude);
      _cityController.text = w.city;
      _setResult(w, f);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _startLoading() => setState(() {
        _isLoading = true;
        _error = null;
        _weather = null;
        _forecast = null;
      });

  void _setResult(WeatherModel w, ForecastModel f) {
    setState(() {
      _weather = w;
      _forecast = f;
      _isLoading = false;
    });
    widget.onWeatherLoaded?.call(w);
    _animController.forward(from: 0);
  }

  void _setError(String e) => setState(() {
        _error = e.replaceAll('Exception: ', '');
        _isLoading = false;
      });

  String _emoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear')) return '☀️';
    if (c.contains('few clouds')) return '🌤️';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('heavy rain')) return '🌧️';
    if (c.contains('rain')) return '🌦️';
    if (c.contains('drizzle')) return '🌦️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) return '🌫️';
    return '🌡️';
  }

  Color _goColor(String text) {
    if (text.startsWith('Yes')) return const Color(0xFF34D399);
    if (text.startsWith('Maybe')) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(_weather?.condition);

    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 56, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo row
                  Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, accent.withOpacity(0.5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('VC',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('VibeCast',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5)),
                    const Spacer(),
                    if (_weather != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accent.withOpacity(0.25)),
                        ),
                        child: Text(
                          'Live',
                          style: TextStyle(
                              fontSize: 11,
                              color: accent,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 24),

                  // Search row
                  Row(children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF111120),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.07)),
                        ),
                        child: TextField(
                          controller: _cityController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _fetchWeather(),
                          decoration: const InputDecoration(
                            hintText: 'Search city...',
                            hintStyle: TextStyle(
                                color: Colors.white30, fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: Colors.white30, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isLoading ? null : _fetchByLocation,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111120),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.07)),
                        ),
                        child: Icon(Icons.my_location_rounded,
                            color: accent, size: 20),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),

                  // Search button
                  GestureDetector(
                    onTap: _isLoading ? null : _fetchWeather,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [Colors.white12, Colors.white12]
                              : [accent, accent.withOpacity(0.7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: accent.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                )
                              ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Get Weather',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Error ───────────────────────────────────────────────────────
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF87171).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFF87171).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFF87171), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFF87171),
                                fontSize: 13,
                                height: 1.5))),
                  ]),
                ),
              ),
            ),

          // ── Empty state ────────────────────────────────────────────────
          if (_weather == null && !_isLoading && _error == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C6FFF).withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF7C6FFF).withOpacity(0.15),
                            width: 1.5),
                      ),
                      child: const Center(
                          child:
                              Text('🌍', style: TextStyle(fontSize: 44))),
                    ),
                    const SizedBox(height: 20),
                    const Text('What\'s the vibe outside?',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    Text('Search a city or use your location',
                        style: TextStyle(
                            fontSize: 13, color: Colors.white.withOpacity(0.35))),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

          // ── Weather content ────────────────────────────────────────────
          if (_weather != null)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                  child: Column(
                    children: [
                      _buildHeroCard(_weather!, accent),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _buildGoOutside(_weather!, accent)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOutfit(_weather!, accent)),
                      ]),
                      const SizedBox(height: 12),
                      _buildAISummary(_weather!, accent),
                      if (_forecast != null) ...[
                        const SizedBox(height: 20),
                        _buildForecastHeader(),
                        const SizedBox(height: 10),
                        _buildForecast(_forecast!, accent),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Hero weather card ───────────────────────────────────────────────────
  Widget _buildHeroCard(WeatherModel w, Color accent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.18),
            const Color(0xFF0F0F1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.city,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('${w.temperature.toStringAsFixed(1)}°',
                          style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                    color: accent.withOpacity(0.4),
                                    blurRadius: 30)
                              ])),
                    ],
                  ),
                ),
                Text(_emoji(w.condition),
                    style: const TextStyle(fontSize: 52)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                w.condition.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: accent,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.06),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem('🌡️', 'Feels like', '${w.feelsLike.toStringAsFixed(1)}°C'),
                _statItem('💧', 'Humidity', '${w.humidity}%'),
                _statItem('💨', 'Wind', '${w.windSpeed} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$emoji  $label',
            style: const TextStyle(fontSize: 11, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Go outside card ─────────────────────────────────────────────────────
  Widget _buildGoOutside(WeatherModel w, Color accent) {
    final color = _goColor(w.goOutside);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Go outside?',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(_goOutsideEmoji(w.goOutside),
              style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(w.goOutside,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                  height: 1.4)),
        ],
      ),
    );
  }

  String _goOutsideEmoji(String text) {
    if (text.startsWith('Yes')) return '🟢';
    if (text.startsWith('Maybe')) return '🟡';
    return '🔴';
  }

  // ── Outfit card ─────────────────────────────────────────────────────────
  Widget _buildOutfit(WeatherModel w, Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outfit',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          const Text('👕', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(w.outfit,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4)),
        ],
      ),
    );
  }

  // ── AI Summary ──────────────────────────────────────────────────────────
  Widget _buildAISummary(WeatherModel w, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                Text('✦', style: TextStyle(fontSize: 10, color: accent)),
                const SizedBox(width: 4),
                Text('VibeCast AI',
                    style: TextStyle(
                        fontSize: 10,
                        color: accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Text(w.summary,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.8,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // ── Forecast ────────────────────────────────────────────────────────────
  Widget _buildForecastHeader() {
    return Row(children: [
      const Text('5-Day Forecast',
          style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
    ]);
  }

  Widget _buildForecast(ForecastModel f, Color accent) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: f.forecast.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = f.forecast[i];
          final isToday = day.day == 'Today';
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 88,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: isToday
                  ? accent.withOpacity(0.12)
                  : const Color(0xFF0F0F1C),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isToday
                    ? accent.withOpacity(0.35)
                    : Colors.white.withOpacity(0.06),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day.day,
                    style: TextStyle(
                        fontSize: 11,
                        color: isToday ? accent : Colors.white54,
                        fontWeight: FontWeight.w600)),
                Text(_emoji(day.condition),
                    style: const TextStyle(fontSize: 26)),
                Column(children: [
                  Text('${day.maxTemp.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                  Text('${day.minTemp.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white30)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
