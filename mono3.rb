class Mono3 < Formula
  homepage "http://www.mono-project.com/"
  url "http://download.mono-project.com/sources/mono/mono-3.12.1.tar.bz2"
  sha256 "5d8cf153af2948c06bc9fbf5088f6834868e4db8e5f41c7cff76da173732b60d"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "3a1d9b0a386f082a5e0470b29abac04ad06c20b142d9d2d42a0eeb0910bff310" => :yosemite
    sha256 "ae323b1533f892e769b2cd9ef518a24cce0cc55cb2f0d0e494661d6d5aa479e2" => :mavericks
    sha256 "3bc5cc111d9003c6e21480a39595dc4756cffcf33f58c548886ab6df5b0e8944" => :mountain_lion
  end

  keg_only "Conflicts with mono in main repository."

  # xbuild requires the .exe files inside the runtime directories to
  # be executable
  skip_clean "lib/mono"

  resource "monolite" do
    url "http://storage.bos.xamarin.com/mono-dist-master/cb/cb33b94c853049a43222288ead1e0cb059b22783/monolite-111-latest.tar.gz"
    sha256 "a957383beb5a7b6fbe39f7cc9a67a7eb2908b7aadc3f4bacee7853dfeed84dfb"
  end

  def install
    # a working mono is required for the the build - monolite is enough
    # for the job
    (buildpath+"mcs/class/lib/monolite").install resource("monolite")

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-nls=no
    ]

    args << "--build=" + (MacOS.prefer_64_bit? ? "x86_64": "i686") + "-apple-darwin"

    system "./configure", *args
    system "make"
    system "make", "install"
    # mono-gdb.py and mono-sgen-gdb.py are meant to be loaded by gdb, not to be
    # run directly, so we move them out of bin
    libexec.install bin/"mono-gdb.py", bin/"mono-sgen-gdb.py"
  end

  test do
    test_str = "Hello Homebrew"
    test_name = "hello.cs"
    (testpath/test_name).write <<-EOS.undent
      public class Hello1
      {
         public static void Main()
         {
            System.Console.WriteLine("#{test_str}");
         }
      }
    EOS
    shell_output "#{bin}/mcs #{test_name}"
    output = shell_output "#{bin}/mono hello.exe"
    assert_match test_str, output.strip

    # Tests that xbuild is able to execute lib/mono/*/mcs.exe
    (testpath/"test.csproj").write <<-EOS.undent
      <?xml version="1.0" encoding="utf-8"?>
      <Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
        <PropertyGroup>
          <AssemblyName>HomebrewMonoTest</AssemblyName>
        </PropertyGroup>
        <ItemGroup>
          <Compile Include="#{test_name}" />
        </ItemGroup>
        <Import Project="$(MSBuildBinPath)\\Microsoft.CSharp.targets" />
      </Project>
    EOS
    shell_output "#{bin}/xbuild test.csproj"
  end

  def caveats; <<-EOS.undent
    To use the assemblies from other formulae you need to set:
      export MONO_GAC_PREFIX="#{HOMEBREW_PREFIX}"
    EOS
  end
end
