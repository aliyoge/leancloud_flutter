/// ************************************
/// @Description:  doucment.dart
/// @Author:  wenjunhuang
/// @Time:  2018/10/18 11:35 AM
/// @Email: kongkonghwj@gmail.com
/// ************************************

// 用于Stream传递数据，里面包含DocumentSnapshot数组。
class StreamSnapshot {
  /// Gets a list of all the documents included in this snapshot
  final List<DocumentSnapshot> documents;

  StreamSnapshot(Map<dynamic, dynamic> data)
      : documents = new List<DocumentSnapshot>.generate(// 将传入的数组自动转换为DocumentSnapshot数组
      data['documents'].length, (int index) {
    return new DocumentSnapshot(
      _asStringKeyedMap(data['documents'][index]),
    );
  });
}

// 用于表示列表中单个数据。
class DocumentSnapshot {
  DocumentSnapshot(this.data);

  /// Contains all the data of this snapshot
  final Map<String, dynamic> data;

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];

  /// Returns the ID of the snapshot's document
  String get documentID => data["id"];

  /// Returns `true` if the document exists.
  bool get exists => data != null;
}

/// An enumeration of document change types.
enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
class DocumentChange {
  DocumentChange._(Map<dynamic, dynamic> data)
      : oldIndex = data['oldIndex'],
        newIndex = data['newIndex'],
        document = new DocumentSnapshot(
          _asStringKeyedMap(data['document']),
        ),
        type = DocumentChangeType.values.firstWhere((DocumentChangeType type) {
          return type.toString() == data['type'];
        });

  /// The type of change that occurred (added, modified, or removed).
  final DocumentChangeType type;

  /// The index of the changed document in the result set immediately prior to
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange objects
  /// have been applied).
  ///
  /// -1 for [DocumentChangeType.added] events.
  final int oldIndex;

  /// The index of the changed document in the result set immediately after this
  /// DocumentChange (i.e. supposing that all prior [DocumentChange] objects
  /// and the current [DocumentChange] object have been applied).
  ///
  /// -1 for [DocumentChangeType.removed] events.
  final int newIndex;

  /// The document affected by this change.
  final DocumentSnapshot document;
}

Map<String, dynamic> _asStringKeyedMap(Map<dynamic, dynamic> map) {
  if (map == null) return null;
  if (map is Map<String, dynamic>) {
    return map;
  } else {
    return new Map<String, dynamic>.from(map);
  }
}

