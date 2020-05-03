class Chunkwm < Formula
  desc "Tiling window manager for macOS based on plugin architecture"
  homepage "https://github.com/newtonne/chunkwm"
  url "https://github.com/newtonne/chunkwm/archive/v0.4.10.tar.gz"
  sha256 "c9a15713174154725239a70e67fa4628b6f1e545a80fb76edf21a3ea867d93e0"
  head "https://github.com/newtonne/chunkwm.git"

  option "without-tiling", "Do not build tiling plugin."
  option "without-ffm", "Do not build focus-follow-mouse plugin."
  option "without-border", "Do not build border plugin."
  option "with-purify", "Build purify plugin."
  option "with-logging", "Deprecated, here for backward compatibility, does not have effect."
  option "with-tmp-logging", "Deprecated, here for backward compatibility, does not have effect."
  option "without-completions", "Do not install completions."

  depends_on :macos => :el_capitan

  def install
    (var/"log/chunkwm").mkpath
    system "make", "install"
    inreplace "#{buildpath}/examples/chunkwmrc", "~/.chunkwm_plugins", "#{opt_pkgshare}/plugins"
    bin.install "#{buildpath}/bin/chunkwm"
    (pkgshare/"examples").install "#{buildpath}/examples/chunkwmrc"

    system "make", "--directory", "src/chunkc"
    bin.install "#{buildpath}/src/chunkc/bin/chunkc"

    if build.with? "tiling"
      system "make", "install", "--directory", "src/plugins/tiling"
      (pkgshare/"plugins").install "#{buildpath}/plugins/tiling.so"
      (pkgshare/"examples").install "#{buildpath}/src/plugins/tiling/examples/khdrc"
    end

    if build.with? "ffm"
      system "make", "install", "--directory", "src/plugins/ffm"
      (pkgshare/"plugins").install "#{buildpath}/plugins/ffm.so"
    end

    if build.with? "border"
      system "make", "install", "--directory", "src/plugins/border"
      (pkgshare/"plugins").install "#{buildpath}/plugins/border.so"
    end

    if build.with? "purify"
      system "make", "install", "--directory", "src/plugins/purify"
      (pkgshare/"plugins").install "#{buildpath}/plugins/purify.so"
    end

    if build.with? "completions"
        zsh_completion.install "src/completions/_chunkc"
    end
  end

  def caveats; <<~EOS
    Copy the example configuration into your home directory:
      cp #{opt_pkgshare}/examples/chunkwmrc ~/.chunkwmrc
    Opening chunkwm will prompt for Accessibility API permissions. After access
    has been granted, the application must be restarted.
      brew services restart chunkwm
    This has to be done after every update to chunkwm, unless you codesign the
    binary with self-signed certificate before restarting
    Create code signing certificate named "chunkwm-cert" using Keychain Access.app
      codesign -fs "chunkwm-cert" #{opt_bin}/chunkwm
    NOTE: options "--with-logging" and "--with-tmp-logging" are deprecated since now
    chunkwm supports logging through configuration:
      chunkc core::log_file <stdout | stderr | /path/to/file>
    NOTE: plugins folder has been moved to #{opt_pkgshare}/plugins
    EOS
  end

  plist_options :manual => "chunkwm"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/chunkwm</string>
      </array>
      <key>EnvironmentVariables</key>
      <dict>
        <key>PATH</key>
        <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
      </dict>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match "chunkwm #{version}", shell_output("#{bin}/chunkwm --version")
  end
end
