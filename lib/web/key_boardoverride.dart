// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void disableBrowserFindShortcut() {
  html.window.addEventListener('keydown', (event) {
    if (event is html.KeyboardEvent) {
      if ((event.ctrlKey || event.metaKey) && event.key == 'f') {
        event.preventDefault(); // Stops browser Ctrl+F
      }
    }
  });
}
