import 'dart:js' as js;

void removeSplash() {
  try {
    js.context.callMethod('removeSplashFromWeb');
  } catch (e) {
    // Silent catch if JS is missing, though it shouldn't happen on web
  }
}
