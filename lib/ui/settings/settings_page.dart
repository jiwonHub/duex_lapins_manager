import 'package:deux_lapins_manager/core/theme/admin_theme.dart';
import 'package:deux_lapins_manager/core/theme/admin_typography.dart';
import 'package:deux_lapins_manager/core/widgets/page_heading.dart';
import 'package:deux_lapins_manager/domain/models/admin_store_settings.dart';
import 'package:deux_lapins_manager/ui/settings/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _shippingFee = TextEditingController();
  final _freeShipping = TextEditingController();
  final _carrier = TextEditingController();
  final _origin = TextEditingController();
  final _returnAddress = TextEditingController();
  final _csPhone = TextEditingController();
  final _csEmail = TextEditingController();
  final _csHours = TextEditingController();
  final _guide = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    for (final controller in [
      _shippingFee,
      _freeShipping,
      _carrier,
      _origin,
      _returnAddress,
      _csPhone,
      _csEmail,
      _csHours,
      _guide,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _load(AdminStoreSettings settings) {
    if (_loaded) return;
    _loaded = true;
    _shippingFee.text = '${settings.shippingFee}';
    _freeShipping.text = '${settings.freeShippingThreshold}';
    _carrier.text = settings.carrier;
    _origin.text = settings.originAddress;
    _returnAddress.text = settings.returnAddress;
    _csPhone.text = settings.csPhone;
    _csEmail.text = settings.csEmail;
    _csHours.text = settings.csHours;
    _guide.text = settings.defaultGuide;
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsViewModelProvider);
    _load(settingsState.settings);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            eyebrow: '시스템 / 기본 설정',
            title: '기본 설정',
            description: '배송, 출고지, 교환/반품 주소와 고객센터 기본 정보를 관리합니다.',
            trailing: FilledButton(
              onPressed: settingsState.loading || settingsState.saving
                  ? null : _save,
              child: Text(settingsState.saving ? '저장 중...' : '설정 저장'),
            ),
          ),
          if (settingsState.loading) const LinearProgressIndicator(minHeight: 2),
          if (settingsState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(settingsState.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final two = constraints.maxWidth >= 900;
              final shipping = _card(
                '01.',
                '배송 설정',
                [
                  TextField(
                    controller: _shippingFee,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: '배송비'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _freeShipping,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: '무료배송 기준'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _carrier,
                    decoration: const InputDecoration(labelText: '기본 택배사'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _origin,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: '출고지'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _returnAddress,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: '교환/반품 주소'),
                  ),
                ],
              );
              final cs = _card(
                '02.',
                '고객센터 설정',
                [
                  TextField(
                    controller: _csPhone,
                    decoration: const InputDecoration(labelText: '고객센터 연락처'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _csEmail,
                    decoration: const InputDecoration(labelText: '고객센터 이메일'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _csHours,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: '운영시간'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _guide,
                    minLines: 5,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: '기본 안내문구'),
                  ),
                ],
              );
              if (!two) {
                return Column(children: [shipping, const SizedBox(height: 16), cs]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: shipping),
                  const SizedBox(width: 16),
                  Expanded(child: cs),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(String index, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.surface,
        border: Border.all(color: AdminTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(index, style: AdminTypography.label(fontSize: 9, color: AdminTheme.muted)),
          const SizedBox(height: 8),
          Text(title, style: AdminTypography.serif(fontSize: 31)),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Future<void> _save() async {
    final fee = int.tryParse(_shippingFee.text);
    final threshold = int.tryParse(_freeShipping.text);
    if (fee == null || threshold == null || fee < 0 || threshold < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송비와 무료배송 기준을 확인해주세요.')),
      );
      return;
    }
    final settings = AdminStoreSettings(
      shippingFee: fee,
      freeShippingThreshold: threshold,
      carrier: _carrier.text.trim(),
      originAddress: _origin.text.trim(),
      returnAddress: _returnAddress.text.trim(),
      csPhone: _csPhone.text.trim(),
      csEmail: _csEmail.text.trim(),
      csHours: _csHours.text.trim(),
      defaultGuide: _guide.text.trim(),
    );
    try {
      await ref.read(settingsViewModelProvider.notifier).save(settings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기본 설정을 저장했습니다.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 설정 저장 실패: $error')),
      );
    }
  }
}
