class Country {
  final String name;
  final String flagEmoji;
  final String region;
  final String capital;
  final int population;
  final List<String> currencies;
  final List<String> languages;
  final double area;
  final List<String> timezones;
  final String alpha3Code;

  Country({
    required this.name,
    required this.flagEmoji,
    required this.region,
    required this.capital,
    required this.population,
    required this.currencies,
    required this.languages,
    required this.area,
    required this.timezones,
    required this.alpha3Code,
  });

 
  factory Country.fromJson(Map<String, dynamic> json) {
    // 1. Extract the common name safely
    final nameObj = json['name'] as Map<String, dynamic>?;
    final commonName = (nameObj?['common'] as String?) ?? 'Unknown';

    
    final emoji = (json['flag'] as String?) ?? '';

    
    final capitalList = json['capital'] as List<dynamic>?;
    final capitalName = (capitalList != null && capitalList.isNotEmpty)
        ? capitalList.first as String
        : 'N/A';

    
    final List<String> currencyNames = [];
    final currenciesMap = json['currencies'] as Map<String, dynamic>?;
    if (currenciesMap != null) {
      for (var value in currenciesMap.values) {
        if (value is Map<String, dynamic>) {
          final curName = value['name'] as String?;
          if (curName != null) {
            currencyNames.add(curName);
          }
        }
      }
    }

    // 5. Extract Languages (API format is: "languages": {"eng": "English", "spa": "Spanish"})
    final List<String> languageNames = [];
    final languagesMap = json['languages'] as Map<String, dynamic>?;
    if (languagesMap != null) {
      for (var value in languagesMap.values) {
        if (value is String) {
          languageNames.add(value);
        }
      }
    }

    return Country(
      name: commonName,
      flagEmoji: emoji,
      region: (json['region'] as String?) ?? 'Unknown',
      capital: capitalName,
      population: (json['population'] as num?)?.toInt() ?? 0,
      currencies: currencyNames,
      languages: languageNames,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      timezones: (json['timezones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      alpha3Code: (json['cca3'] as String?) ?? 'N/A',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flag': flagEmoji,
      'region': region,
      'capital': [capital],
      'population': population,
      'currencies': {
        for (var cur in currencies) cur: {'name': cur}
      },
      'languages': {
        for (var index = 0; index < languages.length; index++)
          'lang$index': languages[index]
      },
      'area': area,
      'timezones': timezones,
      'cca3': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flagEmoji,
    String? region,
    String? capital,
    int? population,
    List<String>? currencies,
    List<String>? languages,
    double? area,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
