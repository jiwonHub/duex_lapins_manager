import 'package:duex_lapins_manager/core/theme/admin_typography.dart';
import 'package:duex_lapins_manager/core/widgets/status_badge.dart';
import 'package:duex_lapins_manager/domain/models/admin_claim.dart';
import 'package:duex_lapins_manager/domain/models/admin_home_content.dart';
import 'package:duex_lapins_manager/domain/models/admin_inquiry.dart';
import 'package:duex_lapins_manager/domain/models/admin_order.dart';
import 'package:duex_lapins_manager/domain/models/admin_product.dart';
import 'package:flutter/material.dart';

StatusBadge productSaleStatusBadge(AdminProductStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminProductStatus.selling => StatusBadgeTone.success,
      AdminProductStatus.soldOut => StatusBadgeTone.danger,
      AdminProductStatus.hidden => StatusBadgeTone.neutral,
    },
  );
}

StatusBadge productPublishStatusBadge(AdminPublishStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminPublishStatus.draft => StatusBadgeTone.warning,
      AdminPublishStatus.published => StatusBadgeTone.info,
    },
  );
}

StatusBadge contentPublishStatusBadge(AdminContentPublishStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminContentPublishStatus.draft => StatusBadgeTone.warning,
      AdminContentPublishStatus.published => StatusBadgeTone.info,
    },
  );
}

StatusBadge stockQuantityBadge({
  required int quantity,
  required bool isLowStock,
}) {
  return StatusBadge(
    text: '$quantity개',
    tone: quantity <= 0
        ? StatusBadgeTone.danger
        : isLowStock
            ? StatusBadgeTone.warning
            : StatusBadgeTone.success,
  );
}

StatusBadge stockStatusBadge({
  required bool isSoldOut,
  required bool isLowStock,
}) {
  return StatusBadge(
    text: isSoldOut
        ? '품절'
        : isLowStock
            ? '재고 부족'
            : '정상',
    tone: isSoldOut
        ? StatusBadgeTone.danger
        : isLowStock
            ? StatusBadgeTone.warning
            : StatusBadgeTone.success,
  );
}

StatusBadge orderPaymentStatusBadge(AdminPaymentStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminPaymentStatus.pending => StatusBadgeTone.warning,
      AdminPaymentStatus.paid => StatusBadgeTone.success,
      AdminPaymentStatus.refunded => StatusBadgeTone.info,
      AdminPaymentStatus.partialRefunded => StatusBadgeTone.purple,
    },
  );
}

StatusBadge orderStatusBadge(AdminOrderStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminOrderStatus.newOrder => StatusBadgeTone.strong,
      AdminOrderStatus.paid => StatusBadgeTone.info,
      AdminOrderStatus.preparing => StatusBadgeTone.warning,
      AdminOrderStatus.shipped => StatusBadgeTone.purple,
      AdminOrderStatus.delivered => StatusBadgeTone.success,
      AdminOrderStatus.cancelled => StatusBadgeTone.danger,
      AdminOrderStatus.exchangeReturn => StatusBadgeTone.danger,
    },
  );
}

StatusBadge inquiryStatusBadge(AdminInquiryStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminInquiryStatus.unanswered => StatusBadgeTone.danger,
      AdminInquiryStatus.answered => StatusBadgeTone.success,
    },
  );
}

StatusBadge claimTypeBadge(AdminClaimType type) {
  return StatusBadge(
    text: type.label,
    tone: switch (type) {
      AdminClaimType.cancel => StatusBadgeTone.danger,
      AdminClaimType.exchange => StatusBadgeTone.warning,
      AdminClaimType.returnItem => StatusBadgeTone.purple,
    },
  );
}

StatusBadge claimPickupStatusBadge(AdminPickupStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminPickupStatus.notRequired => StatusBadgeTone.neutral,
      AdminPickupStatus.waiting => StatusBadgeTone.warning,
      AdminPickupStatus.requested => StatusBadgeTone.info,
      AdminPickupStatus.collected => StatusBadgeTone.success,
    },
  );
}

StatusBadge claimProcessStatusBadge(AdminClaimProcessStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminClaimProcessStatus.requested => StatusBadgeTone.info,
      AdminClaimProcessStatus.processing => StatusBadgeTone.warning,
      AdminClaimProcessStatus.approved => StatusBadgeTone.teal,
      AdminClaimProcessStatus.rejected => StatusBadgeTone.danger,
      AdminClaimProcessStatus.completed => StatusBadgeTone.success,
    },
  );
}

StatusBadge claimRefundStatusBadge(AdminRefundStatus status) {
  return StatusBadge(
    text: status.label,
    tone: switch (status) {
      AdminRefundStatus.none => StatusBadgeTone.neutral,
      AdminRefundStatus.waiting => StatusBadgeTone.warning,
      AdminRefundStatus.completed => StatusBadgeTone.success,
    },
  );
}

class ProductColorBadge extends StatelessWidget {
  const ProductColorBadge({
    super.key,
    required this.colorName,
  });

  final String colorName;

  @override
  Widget build(BuildContext context) {
    final swatch = _productColor(colorName);
    final normalized = colorName.trim().isEmpty ? '-' : colorName.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        border: Border.all(color: const Color(0xFFCBC5BA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: swatch,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF171511).withValues(alpha: 0.18),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            normalized,
            style: AdminTypography.label(
              fontSize: 9.5,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _productColor(String value) {
    final color = value.trim().toUpperCase();

    if (color.contains('CHARCOAL')) return const Color(0xFF51514E);
    if (color.contains('BLACK')) return const Color(0xFF1E1E1C);
    if (color.contains('NAVY')) return const Color(0xFF26394F);
    if (color.contains('DENIM')) return const Color(0xFF5A7892);
    if (color.contains('BLUE')) return const Color(0xFF527A9B);
    if (color.contains('IVORY')) return const Color(0xFFEAE1CE);
    if (color.contains('WHITE')) return const Color(0xFFF5F4EF);
    if (color.contains('BEIGE')) return const Color(0xFFC8B89B);
    if (color.contains('BROWN')) return const Color(0xFF765744);
    if (color.contains('KHAKI')) return const Color(0xFF78745A);
    if (color.contains('OLIVE')) return const Color(0xFF666B4D);
    if (color.contains('GREEN')) return const Color(0xFF58745E);
    if (color.contains('BURGUNDY') || color.contains('WINE')) {
      return const Color(0xFF713A45);
    }
    if (color.contains('RED')) return const Color(0xFFA34E47);
    if (color.contains('ORANGE')) return const Color(0xFFC97C49);
    if (color.contains('YELLOW')) return const Color(0xFFD2B458);
    if (color.contains('PINK')) return const Color(0xFFC98B96);
    if (color.contains('PURPLE')) return const Color(0xFF755F84);
    if (color.contains('GRAY') || color.contains('GREY')) {
      return const Color(0xFF8B8A84);
    }

    return const Color(0xFF9A958C);
  }
}
