# Maintainer: Your Name <your.email@example.com>
pkgname=tetoimagebrowser
pkgver=3.0.1
pkgrel=1
pkgdesc="tuff Image Browser - A Flutter-based image browser application"
arch=('x86_64')
url="https://internettools.org/"
license=('custom')
depends=('gtk3' 'glibc')
makedepends=('ninja' 'clang' 'cmake' 'pkg-config')
source=()
sha256sums=()

# This PKGBUILD builds from the local source directory
# Make sure you run this from your project directory

build() {
    cd "$startdir"

    # Make sure Flutter is in PATH
    export PATH="$HOME/flutter/bin:$HOME/development/flutter/bin:$PATH"

    # Clean any previous builds
    flutter clean

    # Get dependencies
    flutter pub get

    # Build the Linux application
    flutter build linux --release
}

package() {
    cd "$startdir"
    
    # Create necessary directories
    install -dm755 "$pkgdir/usr/bin"
    install -dm755 "$pkgdir/usr/share/applications"
    install -dm755 "$pkgdir/usr/share/pixmaps"
    install -dm755 "$pkgdir/usr/share/$pkgname"
    
    # Install the application bundle
    cp -r "build/linux/x64/release/bundle/"* "$pkgdir/usr/share/$pkgname/"
    
    # Create a wrapper script
    cat > "$pkgdir/usr/bin/$pkgname" << 'EOF'
#!/bin/bash
cd /usr/share/tetoimagebrowser
exec ./tetoimagebrowser "$@"
EOF
    chmod +x "$pkgdir/usr/bin/$pkgname"
    
    # Install desktop file
    cat > "$pkgdir/usr/share/applications/$pkgname.desktop" << 'EOF'
[Desktop Entry]
Name=tuff Image Browser
Comment=A Flutter-based image browser application
Exec=tetoimagebrowser
Icon=tetoimagebrowser
Type=Application
Categories=Graphics;Photography;Viewer;
StartupNotify=true
EOF
    
    # Install icon (using web favicon as fallback)
    if [ -f "web/favicon.png" ]; then
        install -Dm644 "web/favicon.png" "$pkgdir/usr/share/pixmaps/$pkgname.png"
    fi
    
    # Install macOS icon if available (better quality)
    if [ -f "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" ]; then
        install -Dm644 "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png" "$pkgdir/usr/share/pixmaps/$pkgname.png"
    fi
}
