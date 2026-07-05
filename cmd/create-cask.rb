#!/usr/bin/env ruby
# frozen_string_literal: true

require "English"

module Homebrew
  module Cmd
    class CreateCask < AbstractCommand
      cmd_args do
        description <<~EOS
          Create a new cask using `brew create --cask` and automatically
          inject quarantine-stripping postflight and caveats.

          Passes the URL through to `brew create --cask`. For additional
          options (--set-name, --force, etc.), use `brew create --cask`
          directly and then run `brew strip-quarantine`.
        EOS
        named_args max: 1
      end

      def run
        tap_dir = `brew --repository proitheus/mytap`.chomp
        casks_dir = File.join(tap_dir, "Casks")
        existing = Dir.glob(File.join(casks_dir, "*.rb")).to_set

        url = args.named.first
        odie "URL required" unless url

        puts "==> Creating cask..."
        system("brew", "create", "--cask", url)
        exit($CHILD_STATUS.exitstatus) unless $CHILD_STATUS.success?

        new_files = Dir.glob(File.join(casks_dir, "*.rb"))
                       .reject { |f| existing.include?(f) }

        return if new_files.none?

        token = File.basename(new_files.first, ".rb")
        system("brew", "strip-quarantine", token)
      end
    end
  end
end
