import 'package:flutter/material.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/widgets/post/post_actions.dart';
import 'package:veyra/presentation/widgets/post/post_header.dart';
import 'package:veyra/presentation/widgets/post/post_image.dart';

class PostCard extends StatelessWidget {
  final FeedPost post;

  const PostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppDimensions.spacingSmall,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostHeader(post: post),
        if (post.imageUrl case final imageUrl?) PostImage(imageUrl: imageUrl),
        const PostActions(),
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${post.authorName} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
