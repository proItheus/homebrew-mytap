cask "CHANGEME" do
  version "0.0.0"
  sha256 :no_check

  url "https://example.com/path/to/download.dmg"
  name "AppName"
  desc ""
  homepage ""

  app "AppName.app"

  postflight do
    @cask.artifacts.each do |artifact|
      next unless artifact.is_a?(Cask::Artifact::App)

      system_command "/usr/bin/xattr",
                     args: ["-dr", "com.apple.quarantine", artifact.target.to_s],
                     sudo: false
    rescue
      nil
    end
  end

  caveats do
    source = @cask.tap&.path&/"Casks"/"#{token}.rb"
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
