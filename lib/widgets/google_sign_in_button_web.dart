// Web-specific implementation using dart:html and dart:js
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import 'dart:js' as js;

const String _viewType = 'google-signin-button-view';
bool _registered = false;

void registerGoogleButtonViewFactory() {
  if (_registered) return;
  
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    _viewType,
    (int viewId) {
      final container = html.DivElement()
        ..id = 'google_button_container_$viewId'
        ..style.width = '100%'
        ..style.height = '44px'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      // Renderizar el botón de Google después de un breve delay
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          js.context.callMethod('eval', ['''
            if (window.google && window.google.accounts && window.google.accounts.id) {
              google.accounts.id.renderButton(
                document.getElementById('google_button_container_$viewId'),
                {
                  theme: 'outline',
                  size: 'large',
                  type: 'standard',
                  text: 'signin_with',
                  shape: 'rectangular',
                  logo_alignment: 'left',
                  width: '320'
                }
              );
              console.log('✅ Google button rendered in container $viewId');
            } else {
              console.warn('⚠️ Google SDK not loaded yet');
            }
          ''']);
        } catch (e) {
          print('❌ Error rendering Google button: $e');
        }
      });

      return container;
    },
  );
  
  _registered = true;
}

Widget buildWebButton() {
  return const HtmlElementView(viewType: _viewType);
}
