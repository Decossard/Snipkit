import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppIcons {
  AppIcons._();

  // ── Navigation ──────────────────────────────
  static const IconData chatBubble = LucideIcons.messageCircle;
  static const IconData chatBubbleFilled = LucideIcons.messageCircle;
  static const IconData personCircle = LucideIcons.userCircle;
  static const IconData personCircleFilled = LucideIcons.userCircle;

  // ── Actions ─────────────────────────────────
  static const IconData arrowLeft = LucideIcons.arrowLeft;
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData xClose = LucideIcons.x;
  static const IconData plus = LucideIcons.plus;
  static const IconData send = LucideIcons.arrowRight;
  static const IconData sendArrow = LucideIcons.cornerUpRight;
  static const IconData camera = LucideIcons.camera;
  static const IconData microphone = LucideIcons.mic;
  static const IconData articlePage = LucideIcons.fileText;
  static const IconData imagePhoto = LucideIcons.image;
  static const IconData copy = LucideIcons.copy;
  static const IconData pencilEdit = LucideIcons.pencil;
  static const IconData trashDelete = LucideIcons.trash2;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData infoCircle = LucideIcons.info;
  static const IconData checkCircle = LucideIcons.checkCircle2;
  static const IconData xCircle = LucideIcons.xCircle;
  static const IconData lockClosed = LucideIcons.lock;
  static const IconData clock = LucideIcons.clock;
  static const IconData warningTriangle = LucideIcons.alertTriangle;
  static const IconData settings = LucideIcons.settings2;
  static const IconData person = LucideIcons.user;
  static const IconData wifiOff = LucideIcons.wifiOff;
  static const IconData saveDownload = LucideIcons.download;
  static const IconData playCircle = LucideIcons.playCircle;
  static const IconData saveNotification = LucideIcons.bellRing;
  static const IconData search = LucideIcons.search;
  static const IconData pin = LucideIcons.pin;
  static const IconData bellOff = LucideIcons.bellOff;
  static const IconData bell = LucideIcons.bell;
  static const IconData archive = LucideIcons.archive;
  static const IconData block = LucideIcons.ban;
  static const IconData logOut = LucideIcons.logOut;
  static const IconData check = LucideIcons.check;
  static const IconData fileDocument = LucideIcons.fileText;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;

  // ── Icon sizes ───────────────────────────────
  static const double large = 24;
  static const double medium = 20;
  static const double small = 16;
}

/// Convenience widget that renders an AppIcon with correct size and color.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIcons.large,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}
