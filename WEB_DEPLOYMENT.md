# Running Streak it on Web

## 🌐 Quick Start - Flutter Web

### Prerequisites
You need Flutter installed with web support enabled.

### Step 1: Install Flutter (if not already installed)

**Linux/macOS:**
```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/flutter/bin:$PATH"

# Verify installation
flutter doctor
```

**Windows:**
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to C:\src\flutter
3. Add C:\src\flutter\bin to PATH
4. Run `flutter doctor`

### Step 2: Enable Flutter Web Support

```bash
# Enable web support
flutter config --enable-web

# Verify web is available
flutter devices
# Should show "Chrome" and "Web Server" in the list
```

### Step 3: Run on Web

**Option A: Chrome Browser (Recommended for Development)**
```bash
cd /workspaces/Streak-it
flutter pub get
flutter run -d chrome
```

**Option B: Web Server (for deployment)**
```bash
cd /workspaces/Streak-it
flutter pub get
flutter run -d web-server --web-port=8080
```

Then open: http://localhost:8080

**Option C: Edge Browser**
```bash
flutter run -d edge
```

### Step 4: Build for Production

```bash
# Build optimized web app
flutter build web

# Output will be in: build/web/
# Deploy these files to any web server
```

## 🚀 Production Deployment

After running `flutter build web`, you'll get these files in `build/web/`:
```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
├── canvaskit/
└── icons/
```

### Deploy to Popular Platforms

#### GitHub Pages
```bash
# Build
flutter build web --base-href "/Streak-it/"

# Push to gh-pages branch
cd build/web
git init
git add .
git commit -m "Deploy to GitHub Pages"
git branch -M gh-pages
git remote add origin https://github.com/numaan7/Streak-it.git
git push -f origin gh-pages
```

Then enable GitHub Pages in repository settings.

#### Netlify
```bash
# Build
flutter build web

# Deploy
cd build/web
netlify deploy --prod
```

Or connect your GitHub repo to Netlify for automatic deployments.

#### Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Build and deploy
flutter build web
cd build/web
vercel --prod
```

#### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Build
flutter build web

# Deploy
firebase deploy
```

#### Apache/Nginx (Traditional Hosting)
```bash
# Build
flutter build web

# Copy build/web/* to your web server directory
cp -r build/web/* /var/www/html/streak-it/
```

## 🐛 Common Issues & Solutions

### Issue: "Chrome not found"
**Solution:**
```bash
# Set Chrome path
export CHROME_EXECUTABLE=/usr/bin/google-chrome
# or
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

### Issue: CORS errors in development
**Solution:** Use Chrome with disabled web security for development:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Issue: App not loading in production
**Solution:** Check the base href in index.html:
```html
<base href="/">
<!-- or for subdirectory -->
<base href="/your-subdirectory/">
```

### Issue: Assets not loading
**Solution:** Rebuild with correct base-href:
```bash
flutter build web --base-href "/your-path/"
```

## 🔧 Development Tips

### Hot Reload on Web
When running with `flutter run -d chrome`, you can:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug in Browser
1. Open Chrome DevTools (F12)
2. Go to Console for logs
3. Use Network tab to debug API calls
4. Use Application tab to check localStorage

### Performance Optimization
```bash
# Build with optimizations
flutter build web --release --web-renderer html

# Or use CanvasKit for better graphics
flutter build web --release --web-renderer canvaskit

# Auto-select best renderer
flutter build web --release --web-renderer auto
```

## 📱 PWA Support

Streak it can work as a Progressive Web App!

### Step 1: Update manifest.json
File is auto-generated in `web/manifest.json`. Customize:
```json
{
  "name": "Streak it",
  "short_name": "Streak it",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0D0D0D",
  "theme_color": "#6C5CE7",
  "description": "Vibe check your habits",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [...]
}
```

### Step 2: Test PWA
1. Build: `flutter build web`
2. Serve locally: `python3 -m http.server 8000 -d build/web`
3. Open: http://localhost:8000
4. Install from Chrome menu: "Install Streak it"

## 🌍 Browser Compatibility

### Supported Browsers
- ✅ Chrome (Recommended)
- ✅ Edge
- ✅ Firefox
- ✅ Safari (macOS/iOS)
- ✅ Opera

### Minimum Versions
- Chrome 84+
- Edge 84+
- Firefox 76+
- Safari 13.1+

## 🎨 Web-Specific Optimizations

### Reduce Initial Load Time
```bash
# Use split-debug-info
flutter build web --split-debug-info=./debug-info

# Use deferred loading
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=false
```

### Customize Loading Screen
Edit `web/index.html` to customize the loading indicator.

## 📊 Analytics (Optional)

Add Google Analytics to `web/index.html`:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=YOUR-ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'YOUR-ID');
</script>
```

## 🔒 Security

### HTTPS Requirement
For PWA features and service workers, you need HTTPS in production.

### Content Security Policy
Add to `web/index.html` if needed:
```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'">
```

## 📦 Quick Commands Reference

```bash
# Run in Chrome
flutter run -d chrome

# Run on web server
flutter run -d web-server

# Build for production
flutter build web

# Build with custom settings
flutter build web --release --web-renderer auto

# Serve locally after build
python3 -m http.server 8000 -d build/web
# or
npx serve build/web

# Check available devices
flutter devices
```

## 🎯 Local Testing

After building, you can test locally:

**Python 3:**
```bash
cd build/web
python3 -m http.server 8080
```

**Node.js (http-server):**
```bash
npx http-server build/web -p 8080
```

**PHP:**
```bash
cd build/web
php -S localhost:8080
```

Then open: http://localhost:8080

## ✅ Checklist for Web Deployment

- [ ] Flutter web support enabled (`flutter config --enable-web`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds successfully (`flutter build web`)
- [ ] Test locally before deploying
- [ ] Configure base-href if deploying to subdirectory
- [ ] Set up HTTPS for production
- [ ] Test on multiple browsers
- [ ] Check mobile responsiveness
- [ ] Optimize assets and images
- [ ] Configure caching headers
- [ ] Set up analytics (optional)
- [ ] Test PWA installation (optional)

## 🚀 Ready to Deploy!

Your Streak it app is ready for the web. Follow the steps above and share your habit tracker with the world!

---

**Need help?** Check the Flutter web documentation: https://docs.flutter.dev/platform-integration/web
