class Country {
  final String commonName;
  final String officialName;
  final String flagEmoji;
  final String region;
  final String subregion;
  final List<String> capital;
  final int population;
  final double area;
  final List<String> timezones;
  final Map<String, String> currencies;
  final Map<String, String> languages;
  final String alpha3Code;

  const Country({
    required this.commonName,
    required this.officialName,
    required this.flagEmoji,
    required this.region,
    required this.subregion,
    required this.capital,
    required this.population,
    required this.area,
    required this.timezones,
    required this.currencies,
    required this.languages,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Parse currencies: { "USD": { "name": "Dollar", "symbol": "$" } }
    final Map<String, String> parsedCurrencies = {};
    if (json['currencies'] != null) {
      (json['currencies'] as Map<String, dynamic>).forEach((code, value) {
        final name = (value as Map<String, dynamic>)['name'] as String? ?? code;
        parsedCurrencies[code] = name;
      });
    }

    // Parse languages: { "eng": "English" }
    final Map<String, String> parsedLanguages = {};
    if (json['languages'] != null) {
      (json['languages'] as Map<String, dynamic>).forEach((code, name) {
        parsedLanguages[code] = name as String;
      });
    }

    return Country(
      commonName: (json['name']?['common'] as String?) ?? 'Unknown',
      officialName: (json['name']?['official'] as String?) ?? 'Unknown',
      flagEmoji: (json['flag'] as String?) ?? '',
      region: (json['region'] as String?) ?? 'Unknown',
      subregion: (json['subregion'] as String?) ?? 'Unknown',
      capital: (json['capital'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      population: (json['population'] as int?) ?? 0,
      area: ((json['area'] as num?) ?? 0).toDouble(),
      timezones: (json['timezones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currencies: parsedCurrencies,
      languages: parsedLanguages,
      alpha3Code: (json['cca3'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': commonName, 'official': officialName},
      'flag': flagEmoji,
      'region': region,
      'subregion': subregion,
      'capital': capital,
      'population': population,
      'area': area,
      'timezones': timezones,
      'currencies': currencies,
      'languages': languages,
      'cca3': alpha3Code,
    };
  }

  Country copyWith({
    String? commonName,
    String? officialName,
    String? flagEmoji,
    String? region,
    String? subregion,
    List<String>? capital,
    int? population,
    double? area,
    List<String>? timezones,
    Map<String, String>? currencies,
    Map<String, String>? languages,
    String? alpha3Code,
  }) {
    return Country(
      commonName: commonName ?? this.commonName,
      officialName: officialName ?? this.officialName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}