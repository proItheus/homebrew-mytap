cask "ryubing" do
  version "1.3.3"
  sha256 "e4818bb84c98e0d3120691821e90772099e46101273d3f145ffdb10eee2c0dbb"

  url "https://git.ryujinx.app/projects/Ryubing/releases/download/#{version}/ryujinx-#{version}-macos_universal.app.tar.gz"
  name "Ryubing"
  desc "Fork of Ryujinx, open-source Nintendo Switch emulator"
  homepage "https://ryujinx.app/"

  livecheck do
    url "https://git.ryujinx.app/projects/Ryubing.git"
    strategy :git do |tags|
      tags.filter { |tag| tag.match(/^\d/) }
    end
  end

  depends_on macos: :monterey

  app "Ryujinx.app"

  postflight do
    @cask.artifacts.each do |artifact|
      target = artifact.respond_to?(:target) ? artifact.target : nil
      next unless target&.to_s&.end_with?(".app")

      system_command "/usr/bin/xattr",
                     args: ["-dr", "com.apple.quarantine", target.to_s],
                     sudo: false
    rescue
      nil
    end
  end

  zap trash: [
    "~/Library/Application Support/CrashReporter/Ryujinx_*.plist",
    "~/Library/Application Support/Ryujinx",
    "~/Library/Logs/DiagnosticReports/Ryujinx-*.ips",
    "~/Library/Logs/Ryujinx",
    "~/Library/Preferences/org.ryujinx.Ryujinx.plist",
    "~/Library/Preferences/Ryujinx.plist",
  ]

  caveats do
    source = @cask.tap&.path&.join("Casks", "ryubing.rb")
    <<~EOS
      This cask strips the macOS quarantine attribute from the
      installed app, bypassing Gatekeeper. This poses a security
      risk — it should only be used if you trust the maintainer
      of the proitheus/mytap tap or have personally reviewed the
      cask source at:
        #{source || "the tap's Casks/#{token}.rb"}
    EOS
  end
end
