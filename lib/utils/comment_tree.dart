import '../models/comment.dart';

class CommentTreeNode {
  final Comment comment;
  final int depth;
  final List<CommentTreeNode> children;

  const CommentTreeNode({
    required this.comment,
    required this.depth,
    this.children = const [],
  });
}

/// Builds a Reddit-style ordered tree from flat comments (parent before children).
List<CommentTreeNode> buildCommentTree(List<Comment> comments) {
  final byParent = <String?, List<Comment>>{};
  for (final c in comments) {
    byParent.putIfAbsent(c.parentCommentId, () => []).add(c);
  }
  for (final list in byParent.values) {
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  final flat = <CommentTreeNode>[];

  void walk(String? parentId, int depth) {
    final children = byParent[parentId] ?? [];
    for (final comment in children) {
      final node = CommentTreeNode(comment: comment, depth: depth);
      flat.add(node);
      walk(comment.id, depth + 1);
    }
  }

  walk(null, 0);
  return flat;
}
