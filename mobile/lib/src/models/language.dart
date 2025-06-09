class Language {
  final int id;
  final String name;

  Language.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
