{ stdenv, fetchzip, scons, python, pythonPackages, curl, openssl }:

stdenv.mkDerivation rec {
  name = "percona-server-mongodb-${version}";
  version = "4.0.10-5";

  src = fetchzip {
    url = "https://www.percona.com/downloads/percona-server-mongodb-LATEST/percona-server-mongodb-${version}/source/tarball/percona-server-mongodb-${version}.tar.gz";
    sha256 = "0cpx3bqv799ab84wagbicbac46sfyp28iajijz7m0ll49as4qa46";
  };

  nativeBuildInputs = [ scons ];
  buildInputs = [
    python
    curl
    openssl.dev
    openssl.out
  ] ++ (with pythonPackages; [
    pyyaml
    typing
    regex
    cheetah
  ]);

  postPatch = ''
    # fix environment variable reading
    substituteInPlace SConstruct \
        --replace "env = Environment(" "env = Environment(ENV = os.environ,"
  '';

  preBuild = ''
    sconsFlags+=" CC=$CC"
    sconsFlags+=" CXX=$CXX"
  '';

  sconsFlags = [
    "--ssl"
    "--disable-warnings-as-errors"
  ];

  prefixKey = "--prefix=";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://www.percona.com/software/mongo-database/percona-server-for-mongodb;
    description = "A free and open-source drop-in replacement for MongoDB Community Edition";
    platforms = platforms.linux;
    licenses = with licenses; [ agpl3 asl2 ];
    maintainers = with maintainers; [ willibutz ];
  };
}
