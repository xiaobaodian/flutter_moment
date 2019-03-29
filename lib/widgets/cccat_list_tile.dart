import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CatListTile extends StatelessWidget {
  const CatListTile({
    Key key,
    this.leading,
    @required this.title,
    this.subtitle,
    this.trailText,
    this.trailing,
    this.leadingSpace = 16,
    this.contentPadding,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
  }): super(key: key);

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailText;
  final Widget trailing;
  final double leadingSpace;
  final EdgeInsets contentPadding;
  final bool enabled;
  final bool selected;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  Color _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.iconColor != null)
      return tileTheme.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected ? theme.accentColor : null; // null - use current icon theme color
    }
    assert(theme.brightness != null);
    return null;
  }

  Color _textColor(ThemeData theme, ListTileTheme tileTheme, Color defaultColor) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.textColor != null)
      return tileTheme.textColor;

    if (selected) {
      switch (theme.brightness) {
        case Brightness.light:
          return theme.primaryColor;
        case Brightness.dark:
          return theme.accentColor;
      }
    }
    return defaultColor;
  }

  TextStyle _titleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    TextStyle style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.body2;
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subhead;
          break;
      }
    } else {
      style = theme.textTheme.subhead;
    }
    final Color color = _textColor(theme, tileTheme, style.color);
    return style.copyWith(color: color);
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.body1;
    final Color color = _textColor(theme, tileTheme, theme.textTheme.caption.color);
    return style.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    IconThemeData iconThemeData;
    if (leading != null || trailing != null)
      iconThemeData = IconThemeData(color: _iconColor(theme, tileTheme));

    Widget leadingIcon;
    if (leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: leading,
      );
    }

    final TextStyle titleStyle = _titleTextStyle(theme, tileTheme);
    final Widget titleText = AnimatedDefaultTextStyle(
        style: titleStyle,
        duration: kThemeChangeDuration,
        child: title ?? const SizedBox()
    );

    Widget subtitleText;
    TextStyle subtitleStyle;
    if (subtitle != null) {
      subtitleStyle = _subtitleTextStyle(theme, tileTheme);
      subtitleText = AnimatedDefaultTextStyle(
        style: subtitleStyle,
        duration: kThemeChangeDuration,
        child: subtitle,
      );
    }

    Widget trailNoteText;
    TextStyle trailTextStyle;
    if (trailText != null) {
      trailTextStyle = _subtitleTextStyle(theme, tileTheme);
      trailNoteText = AnimatedDefaultTextStyle(
        style: trailTextStyle,
        duration: kThemeChangeDuration,
        child: trailText,
      );
    }

    Widget trailingIcon;
    if (trailing != null) {
      trailingIcon = IconTheme.merge(
        data: iconThemeData,
        child: trailing,
      );
    }

    List<Widget> tileList = [], startList = [], titleList = [], endList = [];

    titleList.add(titleText);
    if (subtitle != null) titleList.add(subtitleText);

    if (leading != null) startList.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, leadingSpace, 0),
        child: leadingIcon,
      )
    );
    startList.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: titleList,
      ),
    );

    if (trailText != null) endList.add(trailNoteText);
    if (trailing != null) endList.add(trailingIcon);

    tileList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: startList,
      ),
    );
    if (endList.length > 0) tileList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: endList,
      ),
    );

    EdgeInsets _contentPadding = contentPadding == null ? const EdgeInsets.fromLTRB(16, 12, 8, 12) : contentPadding;

    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: Padding(
        padding: _contentPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: tileList,
        ),
      ),
    );
  }
}
