# url and sha256 are updated by .github/workflows/update.yml to the newest
# tag v* in finnove/notes-md.
class NotesMd < Formula
  desc "Export Apple Notes to markdown files with YAML frontmatter"
  homepage "https://github.com/finnove/notes-md"
  url "https://github.com/finnove/notes-md/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "GPL-3.0-only"
  head "https://github.com/finnove/notes-md.git", branch: "main"

  depends_on :macos
  depends_on "pandoc"
  depends_on "ruby"

  def install
    libexec.install Dir["*"]
    ENV["GEM_HOME"] = libexec/"gems"
    # The gem versions and checksums in Gemfile.lock, nothing else: a gem
    # whose checksum does not match stops the install.
    ENV["BUNDLE_FROZEN"] = "true"
    cd libexec do
      system "bundle", "install"
    end
    # Homebrew's ruby, with the gems installed here, also when another ruby
    # comes first in PATH.
    (bin/"notes").write_env_script libexec/"notes",
      GEM_HOME: libexec/"gems",
      PATH:     "#{Formula["ruby"].opt_bin}:$PATH"
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
