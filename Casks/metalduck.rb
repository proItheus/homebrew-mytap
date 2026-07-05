cask "metalduck" do
  version "0.1.1"
  sha256 "0b282ddb9042c8a983e3137c81346da2497ee95760e48c0494f717294dfe1d16"

  url "https://github.com/Nycolazs/MetalDuck/releases/download/v#{version}/MetalDuck-macos-arm64.dmg"
  name "Metalduck"
  desc "Experimental real-time scaler inspired by Lossless Scaling, using metal"
  homepage "https://github.com/Nycolazs/MetalDuck"

  depends_on macos: :sequoia

  app "MetalDuck.app"

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

  caveats do
    source = @cask.tap&.path&.join("Casks", "metalduck.rb")
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
