class Docker133 < Formula
  homepage "https://www.docker.com/"
  # Boot2docker and docker are generally updated at the same time.
  # Please update the version of boot2docker too
  url "https://github.com/docker/docker.git", :tag => "v1.3.3"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha1 "efa8a6c570d0aa167dc13451636e569378b4e13a" => :yosemite
    sha1 "339d5b573e10c456228fe0f224af63b84c8c6f91" => :mavericks
    sha1 "f60f9d8815545837169eebafdf328d914f9b6156" => :mountain_lion
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
