# url and sha256 are updated by .github/workflows/update.yml to the newest
# tag v* in finnove/notes-md.
class NotesMd < Formula
  desc "Export Apple Notes to markdown files with YAML frontmatter"
  homepage "https://github.com/finnove/notes-md"
  url "https://github.com/finnove/notes-md/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "1c6ebde9c9c79e7ab282cb0a16ccccb989fff22abe1270fccad7f7c4775f6f6c"
  license "GPL-3.0-only"
  head "https://github.com/finnove/notes-md.git", branch: "main"

  depends_on :macos
  depends_on "pandoc"
  depends_on "ruby"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "sqlite"

  deny_network_access!

  # The gems in Gemfile.lock, downloaded and checked against their checksums
  # before install, which runs without network.
  def fetch
    ENV["BUNDLE_PATH"] = ".bundle"

    system "bundle", "cache", "--no-install"
  end

  # As homebrew-core does for Ruby tools (ronn-ng, licensed): the gems in
  # Gemfile.lock, then notes-md itself as a gem, all in libexec.
  def install
    ENV["GEM_HOME"] = libexec
    # The gem versions in Gemfile.lock, nothing else.
    ENV["BUNDLE_FROZEN"] = "true"

    # Built from source against the libraries in macOS.
    system "bundle", "config", "set", "build.nokogiri", "--use-system-libraries"
    system "bundle", "config", "set", "build.sqlite3", "--enable-system-libraries"
    system "bundle", "install", "--local"
    system "gem", "build", "#{name}.gemspec"
    system "gem", "install", "--ignore-dependencies", "#{name}-#{version}.gem"

    bin.install libexec/"bin/notes"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  def caveats
    <<~EOS
      notes export creates ~/notes as a git repo the first time.

      macOS asks whether the terminal may control Notes; answer OK.
      If reading NoteStore.sqlite fails, give the terminal Full Disk Access
      in System Settings → Privacy & Security.

      Settings, as environment variables (e.g. in ~/.zshrc):
        NOTES_ROOT                    the archive (default ~/notes)
        NOTES_BASELINE                the baseline folder (default ~/notes.baseline)
        NOTES_LANG=nb                 Norwegian section headings
        NOTES_BOLD_LINE_AS_HEADING=1  a line that is only bold becomes a ## heading
        NOTES_LIMIT_FOLDER            sync only this folder in Notes
        TZ                            time zone for dates (e.g. Europe/Oslo)
      All of them: the README, https://github.com/finnove/notes-md
    EOS
  end

  test do
    assert_match "Usage: notes", shell_output("#{bin}/notes 2>&1", 1)
  end
end
