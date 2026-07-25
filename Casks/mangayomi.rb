cask "mangayomi" do
  version "0.8.0"
  sha256 "0df902e6cbb64720f89e2242d9970e79d8701df43026a7f211fc08a646cf730a"

  url "https://github.com/kodjodevf/mangayomi/releases/download/v#{version}/Mangayomi-v#{version}-macos.dmg"
  name "Mangayomi"
  desc "Free and open source cross-platform manga, novel, and anime reader"
  homepage "https://github.com/kodjodevf/mangayomi"

  depends_on macos: :big_sur

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
