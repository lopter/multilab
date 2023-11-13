{ lib
, buildPythonPackage
, certbot
, fetchPypi
, hvac
, pyopenssl
, zope_interface
}:
buildPythonPackage rec {
  pname = "certbot-vault";
  version = "0.3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qPGpcpHVIpIuJJlOOJVf2pgzs5AE9VAVST90qXMLFfk=";
  };

  propagatedBuildInputs = [ certbot hvac pyopenssl zope_interface ];

  meta = with lib; {
    homepage = "https://github.com/deathowl/certbot-vault-plugin";
    description = "Plugin for Certbot to store certificates in HashiCorp Vault";
    licenses = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

