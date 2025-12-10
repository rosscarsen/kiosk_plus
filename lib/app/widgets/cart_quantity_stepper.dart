import 'package:flutter/material.dart';

class CartQuantityStepper extends StatefulWidget {
  final int initialValue;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool outlineBorder;
  final bool allowNegative;
  final double height;
  final double? textSize;

  /// 购物车数量选择器构造函数
  const CartQuantityStepper({
    super.key,

    /// 初始值（默认1）
    this.initialValue = 1,

    /// 最小值（默认1）
    this.min = 1,

    /// 最大值（默认9999）
    this.max = 9999,

    /// 变化回调函数，当数量改变时触发
    required this.onChanged,

    /// 是否显示边框（默认true）
    this.outlineBorder = true,

    /// 是否允许负数（默认false）
    this.allowNegative = false,

    /// 整体高度（可调节大屏显示，默认36）
    this.height = 36,

    /// 数字字号（可选，默认根据高度自动计算）
    this.textSize,
  });

  @override
  State<CartQuantityStepper> createState() => _CartQuantityStepperState();
}

class _CartQuantityStepperState extends State<CartQuantityStepper> {
  late int _value;
  bool _isIncrease = true;

  @override
  void initState() {
    super.initState();
    // 如果允许负数，最小值设为负无穷
    final effectiveMin = widget.allowNegative ? -9999 : widget.min;
    _value = widget.initialValue.clamp(effectiveMin, widget.max);
  }

  /// 更新数值并触发回调
  void _updateValue(int newValue) {
    if (newValue == _value) return;

    // 如果允许负数，最小值设为负无穷
    final effectiveMin = widget.allowNegative ? -9999 : widget.min;

    setState(() {
      _isIncrease = newValue > _value;
      _value = newValue.clamp(effectiveMin, widget.max);
    });

    widget.onChanged(_value);
  }

  /// 增加数量
  void _increment() {
    if (_value < widget.max) _updateValue(_value + 1);
  }

  /// 减少数量
  void _decrement() {
    // 如果允许负数，不检查最小值限制
    if (widget.allowNegative || _value > widget.min) {
      _updateValue(_value - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 如果允许负数，永远可以减少
    final canMinus = widget.allowNegative || _value > widget.min;
    final canAdd = _value < widget.max;

    // 根据高度自动计算合适的内边距
    final padding = widget.height * 0.12;
    // 根据高度自动计算合适的圆角
    final borderRadius = widget.height * 0.5;

    return Container(
      height: widget.height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: theme.colorScheme.surface,
        border: widget.outlineBorder ? Border.all(color: theme.colorScheme.outlineVariant.withAlpha(135)) : null,
        // 根据高度调整阴影效果
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: widget.height * 0.35,
            offset: Offset(0, widget.height * 0.15),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modernButton(icon: Icons.remove_rounded, enabled: canMinus, onTap: _decrement),
          _buildRollNumber(theme),
          _modernButton(icon: Icons.add_rounded, enabled: canAdd, onTap: _increment),
        ],
      ),
    );
  }

  /// 中间数字滚动动画（加上滚上、减下效果）
  Widget _buildRollNumber(ThemeData theme) {
    // 根据高度自动计算数字区域宽度和字体大小
    final numberWidth = widget.height * 1.5;
    final fontSize = widget.textSize ?? widget.height * 0.5;

    return SizedBox(
      width: numberWidth,
      height: widget.height - (widget.height * 0.24), // 减去上下内边距
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final beginOffset = Offset(0, _isIncrease ? 0.8 : -0.8);
            final slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation);

            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            '$_value',
            key: ValueKey(_value),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  /// 左右按钮（美化圆角 + 背景 + 按压反馈）
  Widget _modernButton({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    final theme = Theme.of(context);

    // 根据高度自动计算按钮大小和图标大小
    final buttonSize = widget.height - (widget.height * 0.24); // 减去上下内边距
    final iconSize = buttonSize * 0.5;
    final buttonBorderRadius = buttonSize * 0.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            color: enabled ? theme.colorScheme.primaryContainer : theme.disabledColor.withAlpha(30),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: enabled ? theme.colorScheme.onPrimaryContainer : theme.disabledColor,
          ),
        ),
      ),
    );
  }
}
