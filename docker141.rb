class Docker141 < Formula
  homepage "https://www.docker.com/"
  url "https://github.com/docker/docker.git", :tag => "v1.4.1"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha1 "fa072be59aa298d570dcc2d2ae6c1878fd0d22a7" => :yosemite
    sha1 "74f376168a3a76064a7a586527a4de1f7a97c50f" => :mavericks
    sha1 "c42a04e1e96181d72eb91d0b9e68da53df4c1a29" => :mountain_lion
  end

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  def install
    ENV["GIT_DIR"] = cached_download/".git"
    ENV["AUTO_GOPATH"] = "1"
    ENV["DOCKER_CLIENTONLY"] = "1"

    system "hack/make.sh", "dynbinary"
    bin.install "bundles/#{version}/dynbinary/docker-#{version}" => "docker"

    if build.with? "completions"
      bash_completion.install "contrib/completion/bash/docker"
      zsh_completion.install "contrib/completion/zsh/_docker"
    end
  end

  test do
    system "#{bin}/docker", "--version"
  end
end
