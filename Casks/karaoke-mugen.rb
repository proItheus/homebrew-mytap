cask "karaoke-mugen" do
  version "9.0.52"
  sha256 "aabafab9710e1a41aab788056890f220eb2a3166ae432e9a25527e80f2f67da1"

  url "https://mugen.karaokes.moe/downloads/Karaoke%20Mugen-#{version}-mac-arm64.dmg"
  name "karaoke_mugen"
  desc "Playlist manager and player for video and audio karaoke"
  homepage "https://mugen.karaokes.moe/en/"

  livecheck do
    url "https://gitlab.com/karaokemugen/code/karaokemugen-app.git"
  end

  depends_on macos: :big_sur

  app "Karaoke Mugen.app"

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

  # Documentation: https://docs.brew.sh/Cask-Cookbook#stanza-zap
  zap trash: ""

  caveats do
    source = @cask.tap&.path&.join("Casks", "karaoke-mugen.rb")
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
