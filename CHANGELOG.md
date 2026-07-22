## 0.0.8

* Replaced `github.com` redirect URL with `raw.githubusercontent.com` direct URL to ensure strict Markdown renderers parse the demo image correctly without HTTP 302 redirects.

## 0.0.7

* Updated demo graphic to visually reflect the core functionality of the plugin.

## 0.0.6

* Changed demo image link to an absolute GitHub raw URL to guarantee cross-platform rendering compatibility.

## 0.0.5

* Converted HTML `<img src="demo.png">` tag to standard Markdown `![alt](demo.png)` syntax to fix pub.dev Markdown rendering restrictions.

## 0.0.4

* Fixed missing image rendering issue on pub.dev by moving the demo image out of the `.pubignore` path and into the package root.

## 0.0.3

* Replaced missing demo GIF placeholder with a high-quality static promotional graphic in `README.md`.

## 0.0.2

* Fixed minor display issues in example test suite.
* Automated documentation generation and placeholder configurations.

## 0.0.1

* Initial release of `switch_app_icon`.
* Supports runtime launcher icon switching on Android (Adaptive/Legacy) and iOS.
* Automated CLI for generating, resizing, blending, and injecting icons into manifests.
