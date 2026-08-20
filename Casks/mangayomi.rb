cask "mangayomi" do
  version "0.8.2"
  sha256 "b4031750209922fe7e0cf566ba39d1ebc37b179800ed12c03d3b58f2bc1fe6f2"

  url "https://github.com/kodjodevf/mangayomi/releases/download/v#{version}/Mangayomi-v#{version}-macos.dmg"
  name "Mangayomi"
  desc "Free and open source cross-platform manga, novel, and anime reader"
  homepage "https://github.com/kodjodevf/mangayomi"

  depends_on macos: :monterey

  app "Mangayomi.app"

  # zap trash: ""
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
    "~/Documents/Mangayomi",
    "~/Library/Application Support/com.kodjodevf.mangayomi",
  ]

  caveats do
    source = @cask.tap&.path&.join("Casks", "#{token}.rb")
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
