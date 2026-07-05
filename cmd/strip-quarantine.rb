#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

module Homebrew
  module Cmd
    class StripQuarantine < AbstractCommand
      cmd_args do
        description <<~EOS
          Ensure all casks in the proitheus/mytap tap have quarantine-stripping
          postflight and caveats blocks.

          With no argument, scans all casks in the tap.
          With a cask name argument, targets only that cask.
        EOS
        named_args :cask, max: 1
      end

      def run
        tap_dir = `brew --repository proitheus/mytap`.chomp
        casks_dir = File.join(tap_dir, "Casks")

        if args.named.any?
          target = args.named.first
          filepath = File.join(casks_dir, "#{target}.rb")
          odie "Cask not found: #{filepath}" unless File.exist?(filepath)

          if process_cask(filepath, target)
            nil # message already printed in process_cask
          else
            puts "==> #{target} already has quarantine handling"
          end
        else
          updated = 0
          Dir.glob(File.join(casks_dir, "*.rb")).each do |filepath|
            next if File.basename(filepath).start_with?("_")

            token = File.basename(filepath, ".rb")
            updated += 1 if process_cask(filepath, token)
          end

          if updated.zero?
            puts "==> All casks already have quarantine handling"
          else
            puts "==> Updated #{updated} cask(s)"
          end
        end
      end

      private

      BOILERPLATE = <<~'RUBY'
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
      RUBY

      def process_cask(filepath, token)
        content = File.read(filepath)
        return false if content.include?("com.apple.quarantine")

        indent = detect_indent(content)
        boilerplate = BOILERPLATE.sub(/\#\{token\}/, token)
                                   .gsub(/^/, indent)
                                   .gsub(/[[:blank:]]+\n/, "\n")

        content.sub!(/\nend\s*\z/, "\n#{boilerplate.chomp}\nend\n")
        File.write(filepath, content)
        puts "==> Injected quarantine-stripping into #{token}"
        true
      end

      def detect_indent(content)
        content.scan(/^  (?:version|sha256|url|name|desc|homepage|app|suite|pkg|binary|zap|depends_on)\b/)
               .first
               &.then { |m| m[/(\s*)/] } || "  "
      end
    end
  end
end
