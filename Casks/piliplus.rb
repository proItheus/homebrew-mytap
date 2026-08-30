cask "piliplus" do
  version "2.1.2+5281"
  sha256 "58bca1a6dfb9f492774584a86dfbcd90a40a24c6064c9eb441055e3f71e503d4"

  url "https://github.com/bggRGjQaUbCoE/PiliPlus/releases/latest/download/PiliPlus_macos_#{version}.dmg"
  name "PiliPlus"
  desc "3rd party bilibili client developed with flutter"
  homepage "https://github.com/bggRGjQaUbCoE/PiliPlus"

  livecheck do
    url "https://api.github.com/repos/bggRGjQaUbCoE/PiliPlus/releases/latest"
    strategy :json do |json|
      json["assets"].filter_map do |a|
        a["name"].match(/_macos_(.+)\.dmg$/)&.[](1)
      end.first
    end
  end

  depends_on macos: :monterey

  app "PiliPlus.app"

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
    "~/Library/Application Scripts/com.example.piliplus",
    "~/Library/Application Support/com.example.piliplus",
    "~/Library/Caches/com.example.piliplus",
    "~/Library/Containers/com.example.piliplus",
    "~/Library/WebKit/com.example.piliplus",
  ]

  caveats do
    source = @cask.tap&.path&.join("Casks", "piliplus.rb")
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
