class ResourceLink {
  final String nodeId;
  final String kind;
  final String url;
  final String? label;
  final int? start;
  final int? page;

  ResourceLink({
    required this.nodeId,
    required this.kind,
    required this.url,
    this.label,
    this.start,
    this.page,
  });

  factory ResourceLink.fromJson(Map<String, dynamic> json) {
    return ResourceLink(
      nodeId: json['nodeId'] as String,
      kind: json['kind'] as String,
      url: json['url'] as String,
      label: json['label'] as String?,
      start: (json['start'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
    );
  }
}
