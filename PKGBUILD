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
    
    # Install desktop file (use the one from the build bundle)
    if [ -f "build/linux/x64/release/bundle/share/applications/tetoimagebrowser.desktop" ]; then
        install -Dm644 "build/linux/x64/release/bundle/share/applications/tetoimagebrowser.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
    fi

    # Install icon from Windows resources (now available in Linux build)
    if [ -f "build/linux/x64/release/bundle/data/app_icon.ico" ]; then
        install -Dm644 "build/linux/x64/release/bundle/data/app_icon.ico" "$pkgdir/usr/share/pixmaps/$pkgname.ico"
    fi

    # Also install to hicolor icon theme directory for better desktop integration
    if [ -f "build/linux/x64/release/bundle/share/icons/hicolor/48x48/apps/app_icon.ico" ]; then
        install -dm755 "$pkgdir/usr/share/icons/hicolor/48x48/apps"
        install -Dm644 "build/linux/x64/release/bundle/share/icons/hicolor/48x48/apps/app_icon.ico" "$pkgdir/usr/share/icons/hicolor/48x48/apps/app_icon.ico"
    fi
}
