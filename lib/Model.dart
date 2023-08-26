class LoanSchema {
  final List<Field> fields;

  LoanSchema({required this.fields});

  factory LoanSchema.fromJson(Map<String, dynamic> json) {
    final fieldsList = json['schema']['fields'] as List<dynamic>;
    final fields = fieldsList.map((fieldJson) => Field.fromJson(fieldJson as Map<String, dynamic>)).toList();
    return LoanSchema(fields: fields);
  }
}

class Field {
  final String type;
  final int version;
  final FieldSchema schema;

  Field({required this.type, required this.version, required this.schema});

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      type: json['type'] as String,
      version: json['version'] as int,
      schema: FieldSchema.fromJson(json['schema'] as Map<String, dynamic>),
    );
  }
}

class FieldSchema {
  final String name;
  final String label;
  final bool hidden;
  final bool readonly;
  final List<Option>? options;
  final List<Field>? fields;

  FieldSchema({
    required this.name,
    required this.label,
    required this.hidden,
    required this.readonly,
    this.options,
    this.fields,
  });

  factory FieldSchema.fromJson(Map<String, dynamic> json) {
    return FieldSchema(
      name: json['name'] as String,
      label: json['label'] as String,
      hidden: json['hidden'] == true, // Convert to bool, defaults to false
      readonly: json['readonly'] == true, // Convert to bool, defaults to false
      options: (json['options'] as List<dynamic>?)
          ?.map((optionJson) => Option.fromJson(optionJson as Map<String, dynamic>))
          .toList(),
      fields: (json['fields'] as List<dynamic>?)
          ?.map((fieldJson) => Field.fromJson(fieldJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Option {
  final String key;
  final String value;

  Option({required this.key, required this.value});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }
}
