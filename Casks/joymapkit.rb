cask "joymapkit" do
  version "0.2.0"
  sha256 "2f8acbb1b0d19fe456a7e2f2cfd0e33780e2132cd8ad92e824b0ed874e2d9f2b"

  url "https://github.com/manaporkun/JoyMapKit/releases/download/v#{version}/JoyMapKit-#{version}.dmg"
  name "joymapkit"
  desc "Menu bar app that maps gamepad inputs to keyboard, mouse, and macros"
  homepage "https://github.com/manaporkun/JoyMapKit"

  depends_on macos: :ventura

  app "JoyMapKit.app"

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
  zap trash: "~/Library/Preferences/com.joymapkit.app.plist"

  caveats do
    source = @cask.tap&.path&.join("Casks", "joymapkit.rb")
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
