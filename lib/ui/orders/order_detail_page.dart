import 'package:deux_lapins_manager/app/app_routes.dart';
import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/utils/formatters.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/ui/shared/admin_status_badges.dart';
import 'package:deux_lapins_manager/domain/models/admin_order.dart';
import 'package:deux_lapins_manager/ui/orders/orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  late final TextEditingController _carrier;
  late final TextEditingController _tracking;
  late final TextEditingController _memo;
  final Map<String, String> _itemCarriers = {};
  final Map<String, String> _itemTracking = {};
  AdminOrderStatus? _status;

  @override
  void initState() {
    super.initState();
    final order = ref.read(ordersViewModelProvider.notifier).getById(widget.orderId);
    _carrier = TextEditingController(text: order?.carrier ?? '');
    _tracking = TextEditingController(text: order?.trackingNumber ?? '');
    _memo = TextEditingController(text: order?.adminMemo ?? '');
    _status = order?.status;
  }

  @override
  void dispose() {
    _carrier.dispose();
    _tracking.dispose();
    _memo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(ordersViewModelProvider);
    final vm = ref.read(ordersViewModelProvider.notifier);
    final order = vm.getById(widget.orderId);

    if (order == null) {
      return const Center(child: Text('주문을 찾을 수 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '판매 관리 / 주문 상세',
            title: order.id,
            description: '주문자, 상품, 결제와 배송 정보를 한 화면에서 확인합니다.',
            trailing: OutlinedButton.icon(
              onPressed: () => context.go(AdminRoutePath.orders),
              icon: const Icon(Icons.arrow_back, size: 14),
              label: const Text('주문 목록'),
            ),
          ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final two = constraints.maxWidth >= 980;
              final left = Column(
                children: [
                  _card('01.', '주문 정보', [
                    _row('주문번호', order.id),
                    _row('주문일', formatDate(order.orderedAt)),
                    _row('구매자', order.customerName),
                    _row('연락처', order.phone),
                    _row('배송지', order.address),
                  ]),
                  const SizedBox(height: 16),
                  _itemsCard(order),
                  const SizedBox(height: 16),
                  _card('03.', '결제 정보', [
                    _row('상품금액', formatWon(order.productAmount)),
                    _row('배송비', formatWon(order.shippingFee)),
                    _row('결제금액', formatWon(order.amount)),
                    _rowWidget(
                      '결제상태',
                      orderPaymentStatusBadge(order.paymentStatus),
                    ),
                  ]),
                ],
              );
              final right = Column(
                children: [
                  _card('04.', '배송 정보', [
                    _rowWidget(
                      '현재 상태',
                      orderStatusBadge(_status ?? order.status),
                    ),
                    const SizedBox(height: 2),
                    DropdownButtonFormField<AdminOrderStatus>(
                      value: _status,
                      decoration: const InputDecoration(labelText: '배송/주문 상태'),
                      items: AdminOrderStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _status = value),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _carrier,
                      decoration: const InputDecoration(labelText: '택배사'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _tracking,
                      decoration: const InputDecoration(labelText: '송장번호'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _card('05.', '관리자 메모', [
                    TextField(
                      controller: _memo,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: '관리자 메모를 입력하세요.',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: orderState.saving || orderState.loading
                          ? null
                          : () async {
                        try {
                          await vm.updateOrder(order.copyWith(
                            status: _status ?? order.status,
                            carrier: _carrier.text.trim(),
                            trackingNumber: _tracking.text.trim(),
                            adminMemo: _memo.text.trim(),
                            items: order.items.map((item) {
                              final key = item.variantId.isEmpty
                                  ? item.productId
                                  : item.variantId;

                              return item.copyWith(
                                carrier: _itemCarriers[key] ?? item.carrier,
                                trackingNumber:
                                _itemTracking[key] ?? item.trackingNumber,
                              );
                            }).toList(growable: false),
                          ));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('주문 정보를 저장했습니다.')),
                          );
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('주문 저장 실패: $error')),
                          );
                        }
                      },
                      child: const Text('변경사항 저장'),
                    ),
                  ),
                ],
              );

              if (!two) {
                return Column(
                  children: [left, const SizedBox(height: 16), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: left),
                  const SizedBox(width: 18),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemsCard(AdminOrder order) {
    return _card(
      '02.',
      '구매 상품',
      [
        ...order.items.map(
          (item) => Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AdminTheme.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: AdminTypography.serif(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ProductColorBadge(colorName: item.color),
                          Text(
                            '${item.size} / ${item.quantity}개',
                            style: AdminTypography.label(
                              fontSize: 9.5,
                              color: AdminTheme.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey(
                          'carrier-${item.variantId}-${item.color}-${item.size}',
                        ),
                        initialValue: item.carrier,
                        decoration: const InputDecoration(
                          labelText: '이 상품의 택배사',
                        ),
                        onChanged: (value) {
                          final key = item.variantId.isEmpty
                              ? item.productId
                              : item.variantId;
                          _itemCarriers[key] = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: ValueKey(
                          'tracking-${item.variantId}-${item.color}-${item.size}',
                        ),
                        initialValue: item.trackingNumber,
                        decoration: const InputDecoration(
                          labelText: '이 상품의 운송장번호',
                        ),
                        onChanged: (value) {
                          final key = item.variantId.isEmpty
                              ? item.productId
                              : item.variantId;
                          _itemTracking[key] = value;
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '배송상태: ${item.deliveryStatus}',
                        style: AdminTypography.label(
                          fontSize: 10,
                          color: AdminTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(formatWon(item.amount)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: orderStatusBadge(order.status),
        ),
      ],
    );
  }

  Widget _card(String index, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted)),
          const SizedBox(height: 6),
          Text(title, style: AdminTypography.serif(fontSize: 28)),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _rowWidget(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AdminTypography.label(
                fontSize: 9,
                color: AdminTheme.muted,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted),
            ),
          ),
          Expanded(child: Text(value, style: AdminTypography.body(fontSize: 11.5))),
        ],
      ),
    );
  }
}
