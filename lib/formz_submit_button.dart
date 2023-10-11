library formz_submit_button;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

/// Initialize class
class FormzSubmitButton extends StatefulWidget {
  final FormzSubmissionStatus status;

  /// The callback that is called when
  /// the button is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// The button's label
  final Widget child;

  /// The primary color of the button
  final Color? color;

  /// The vertical extent of the button.
  final double height;

  /// The horizontal extent of the button.
  final double width;

  /// The size of the CircularProgressIndicator
  final double loaderSize;

  /// The stroke width of the CircularProgressIndicator
  final double loaderStrokeWidth;

  /// Whether to trigger the animation on the tap event
  final bool animateOnTap;

  /// The color of the static icons
  final Color valueColor;

  /// The curve of the shrink animation
  final Curve curve;

  /// The radius of the button border
  final double borderRadius;

  /// The duration of the button animation
  final Duration duration;

  /// The elevation of the raised button
  final double elevation;

  /// The color of the button when it is in the error state
  final Color errorColor;

  /// The color of the button when it is in the success state
  final Color? successColor;

  /// The color of the foreground button when it is disabled
  final Color? disabledForegroundColor;

  /// The color of the background button when it is disabled
  final Color? disabledBackgroundColor;

  /// The icon for the success state
  final IconData successIcon;

  /// The icon for the failed state
  final IconData failedIcon;

  /// The success and failed animation curve
  final Curve completionCurve;

  /// The duration of the success and failed animation
  final Duration completionDuration;

  Duration get _borderDuration {
    return Duration(milliseconds: (duration.inMilliseconds / 2).round());
  }

  /// initialize constructor
  const FormzSubmitButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.status = FormzSubmissionStatus.initial,
    this.color = Colors.lightBlue,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 24.0,
    this.loaderStrokeWidth = 2.0,
    this.animateOnTap = true,
    this.valueColor = Colors.white,
    this.borderRadius = 35,
    this.elevation = 2,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCirc,
    this.errorColor = Colors.red,
    this.successColor,
    this.successIcon = Icons.check,
    this.failedIcon = Icons.close,
    this.completionCurve = Curves.elasticOut,
    this.completionDuration = const Duration(milliseconds: 1000),
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
  });

  @override
  State<StatefulWidget> createState() => FormzSubmitButtonState();
}

/// Class implementation
class FormzSubmitButtonState extends State<FormzSubmitButton>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _borderController;
  late AnimationController _checkButtonController;

  late Animation _squeezeAnimation;
  late Animation _bounceAnimation;
  late Animation _borderAnimation;

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: widget.height,
        child: Center(
          child: _onBuildButton(context),
        ),
      );

  Widget _onBuildButton(final BuildContext context) {
    switch (widget.status) {
      case FormzSubmissionStatus.initial:
      case FormzSubmissionStatus.inProgress:
      case FormzSubmissionStatus.canceled:
        return ButtonTheme(
          shape: RoundedRectangleBorder(borderRadius: _borderAnimation.value),
          padding: const EdgeInsets.all(0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              disabledForegroundColor: widget.disabledForegroundColor,
              disabledBackgroundColor: widget.disabledBackgroundColor,
              minimumSize: Size(_squeezeAnimation.value, widget.height),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              backgroundColor: widget.color,
              elevation: widget.elevation,
              padding: const EdgeInsets.all(0),
            ),
            onPressed: widget.onPressed == null ? null : _btnPressed,
            child: widget.status == FormzSubmissionStatus.initial ||
                    widget.status == FormzSubmissionStatus.canceled
                ? widget.child
                : _Loader(
                    loaderSize: widget.loaderSize,
                    loaderStrokeWidth: widget.loaderStrokeWidth,
                    valueColor: widget.valueColor,
                  ),
          ),
        );
      case FormzSubmissionStatus.success:
        return _Check(
          bounceAnimation: _bounceAnimation,
          valueColor: widget.valueColor,
          successColor: widget.successColor,
          successIcon: widget.successIcon,
        );
      case FormzSubmissionStatus.failure:
        return _Cross(
          bounceAnimation: _bounceAnimation,
          errorColor: widget.errorColor,
          valueColor: widget.valueColor,
          failedIcon: widget.failedIcon,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _buttonController =
        AnimationController(duration: widget.duration, vsync: this);
    _checkButtonController =
        AnimationController(duration: widget.completionDuration, vsync: this);
    _borderController =
        AnimationController(duration: widget._borderDuration, vsync: this);
    _bounceAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(
        parent: _checkButtonController,
        curve: widget.completionCurve,
      ),
    );
    _squeezeAnimation =
        Tween<double>(begin: widget.width, end: widget.height).animate(
      CurvedAnimation(parent: _buttonController, curve: widget.curve),
    );
    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(widget.borderRadius),
      end: BorderRadius.circular(widget.height),
    ).animate(_borderController);

    _bounceAnimation.addListener(() => setState(() {}));
    _squeezeAnimation.addListener(() => setState(() {}));
    _borderAnimation.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant final FormzSubmitButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      Future.delayed(Duration.zero, () {
        switch (widget.status) {
          case FormzSubmissionStatus.inProgress:
            inProgress();
            break;
          case FormzSubmissionStatus.failure:
            failure();
            break;
          case FormzSubmissionStatus.success:
            success();
            break;
          case FormzSubmissionStatus.canceled:
            initial();
            break;
          case FormzSubmissionStatus.initial:
            initial();
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _checkButtonController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  void _btnPressed() async {
    if (widget.status.isInitial || widget.status.isCanceled) {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
  }

  void inProgress() {
    if (!mounted) return;
    if (_borderController.isAnimating || _buttonController.isAnimating) {
      return;
    }
    _borderController.forward();
    _buttonController.forward();
  }

  void success() {
    if (!mounted) return;
    _checkButtonController.forward();
  }

  void failure() {
    if (!mounted) return;
    _checkButtonController.forward();
  }

  void initial() async {
    if (!mounted) return;
    unawaited(_buttonController.reverse());
    unawaited(_borderController.reverse());
    _checkButtonController.reset();
  }
}

class _Loader extends StatelessWidget {
  final double loaderSize, loaderStrokeWidth;
  final Color valueColor;

  const _Loader({
    required this.loaderSize,
    required this.loaderStrokeWidth,
    required this.valueColor,
  });
  @override
  Widget build(final BuildContext context) => SizedBox(
        height: loaderSize,
        width: loaderSize,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
          strokeWidth: loaderStrokeWidth,
        ),
      );
}

class _Cross extends StatelessWidget {
  final Animation bounceAnimation;
  final Color errorColor, valueColor;
  final IconData failedIcon;

  const _Cross({
    required this.bounceAnimation,
    required this.errorColor,
    required this.valueColor,
    required this.failedIcon,
  });
  @override
  Widget build(final BuildContext context) => Container(
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: errorColor,
          borderRadius:
              BorderRadius.all(Radius.circular(bounceAnimation.value / 2)),
        ),
        width: bounceAnimation.value,
        height: bounceAnimation.value,
        child: bounceAnimation.value > 20
            ? Icon(failedIcon, color: valueColor)
            : null,
      );
}

class _Check extends StatelessWidget {
  final Animation bounceAnimation;
  final Color valueColor;
  final Color? successColor;
  final IconData? successIcon;
  const _Check({
    required this.bounceAnimation,
    required this.valueColor,
    this.successColor,
    this.successIcon,
  });
  @override
  Widget build(final BuildContext context) => Container(
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: successColor ?? Theme.of(context).primaryColor,
          borderRadius:
              BorderRadius.all(Radius.circular(bounceAnimation.value / 2)),
        ),
        width: bounceAnimation.value,
        height: bounceAnimation.value,
        child: bounceAnimation.value > 20
            ? Icon(successIcon, color: valueColor)
            : null,
      );
}
