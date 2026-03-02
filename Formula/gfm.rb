class Gfm < Formula
  desc "Git Fix Manager - Track bugs and fixes across git branches"
  homepage "https://github.com/RenZan/gitfixmanager"
  url "https://github.com/RenZan/gitfixmanager/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "git"

  def install
    bin.install "gfm"
    lib.install "lib/i18n.sh" if File.exist?("lib/i18n.sh")
    (prefix/"scripts").install "scripts/missing-fix-detector.sh"
    
    # Install shell completions
    bash_completion.install "completions/gfm.bash" if File.exist?("completions/gfm.bash")
    zsh_completion.install "completions/gfm.zsh" if File.exist?("completions/gfm.zsh")
    fish_completion.install "completions/gfm.fish" if File.exist?("completions/gfm.fish")
    
    # Install man page
    man1.install "man/gfm.1" if File.exist?("man/gfm.1")
  end

  test do
    system "#{bin}/gfm", "--version"
  end
end
