import 'package:flutter/material.dart';

/// Utilitas untuk memetakan nama icon string ke IconData Material.
class IconResolver {
  IconResolver._();

  /// Map nama icon ke IconData.
  static const Map<String, IconData> _iconMap = {
    'home': Icons.home_outlined,
    'store': Icons.store_outlined,
    'person': Icons.person_outlined,
    'people': Icons.people_outlined,
    'business': Icons.business_outlined,
    'work': Icons.work_outlined,
    'shopping_cart': Icons.shopping_cart_outlined,
    'inventory': Icons.inventory_2_outlined,
    'category': Icons.category_outlined,
    'folder': Icons.folder_outlined,
    'description': Icons.description_outlined,
    'article': Icons.article_outlined,
    'image': Icons.image_outlined,
    'photo': Icons.photo_outlined,
    'video': Icons.video_library_outlined,
    'music': Icons.music_note_outlined,
    'event': Icons.event_outlined,
    'calendar': Icons.calendar_today_outlined,
    'location': Icons.location_on_outlined,
    'map': Icons.map_outlined,
    'phone': Icons.phone_outlined,
    'email': Icons.email_outlined,
    'message': Icons.message_outlined,
    'chat': Icons.chat_outlined,
    'settings': Icons.settings_outlined,
    'build': Icons.build_outlined,
    'star': Icons.star_outlined,
    'favorite': Icons.favorite_outlined,
    'bookmark': Icons.bookmark_outlined,
    'tag': Icons.label_outlined,
    'link': Icons.link,
    'attach': Icons.attach_file,
    'cloud': Icons.cloud_outlined,
    'download': Icons.download_outlined,
    'upload': Icons.upload_outlined,
    'share': Icons.share_outlined,
    'print': Icons.print_outlined,
    'search': Icons.search,
    'filter': Icons.filter_list,
    'sort': Icons.sort,
    'list': Icons.list,
    'grid': Icons.grid_view,
    'dashboard': Icons.dashboard_outlined,
    'analytics': Icons.analytics_outlined,
    'chart': Icons.bar_chart,
    'money': Icons.attach_money,
    'payment': Icons.payment_outlined,
    'receipt': Icons.receipt_outlined,
    'shipping': Icons.local_shipping_outlined,
    'delivery': Icons.delivery_dining_outlined,
  };

  /// Resolve nama icon string ke [IconData].
  /// Mengembalikan [Icons.widgets_outlined] jika tidak ditemukan.
  static IconData resolve(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.widgets_outlined;
    }
    return _iconMap[iconName] ?? Icons.widgets_outlined;
  }

  /// Daftar nama icon yang tersedia.
  static List<String> get availableIconNames => _iconMap.keys.toList();
}
