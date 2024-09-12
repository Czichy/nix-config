let
  inherit (builtins) attrValues concatLists foldl' map;

  # Users
  users = {
    czichy = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQgoSENg960XY9wU77q8p1+4WgUhEb10xlc27RWcmNE czichy@desktop"];
    # czichy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIABG2T60uEoq4qTZtAZfSBPtlqWs2b4V4O+EptQ6S/ru";
  };

  # Hosts
  machines = {
    HL-1-MRZ-SBC-01 = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPR8KYYsWTQ+sOFMlKXTJU6ZDG84ebHtqI4wotvCYzH"];
    HL-1-OZ-PC-01 = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfYUpuZeYCkKCNL22+jUBroV4gaZYJOjcRVPDZDVXSp root@desktop"];
    # A key for recovery purpose, generated by `ssh-keygen -t ed25519 -a 256 -C "ryan@agenix-recovery"` with a strong passphrase
    # and keeped it offline in a safe place.
    recovery_key = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOIWIyyiKt60nCN3WvFudmP2ju0iaE7PYSoWZj1xu+f czichy@agenix-recovery"];
    # enyo = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG+rKLdFg8Riw1SbwHLbKxGDf+NaOZQPc4ElEN/ra6eu"];
    # hermes = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPShBrtrNRNaYUtIWhn0RHDr759mMcfZjqjJRAfCnWU"];
    # icarus = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWh3pRk2edQkELicwkYFVGKy90sFlluECfTasjCQr1m"];
    # leto = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvw6R8RS6e1tpf5rnFMv+xWQsNk082wRlwTaaFKmIrx0iotP1nE5Tux+uKhx1u71se3LwtzvxvaAcZgqnowq1tZWCeqDWcz7uanDogsmjc+vS54P//gmhWAeAX9ClHIdFBpZSc1+R+aKws9KjJQBOUZi9/07f77AjmxbSDMVeCv5mMF++WjKlE8oJKaa2lLyhxeF5mr2GoNfCkF7FknTrX+mZ6EqW3g0FHHbhqCim4fdTZUberja/W4m2UwWXewgfTUVNowONB8035/BWbBwnxK8i2f2cqdXqF1SVN5SK14Bq7etIc0lJVmLcPz+R6kZPWu6NBF0D92eGBozdzCuJWy/NO/Y6G5Y2tSdFAkkTlpJPM4PA4pQP2XHuohgYOceMtDb4N75ZC10uNiDR/DnwVIa1dzjFQ1ZMfgZ94EwGd9Vy0oklQGrbkAXHA+DPFnc3PTuRUyMgOavI2RxIgYT8LQYWpxc0wGRiBXY/CqbaKSWERxxSlu4Js/0MfRq0GVyxAqE1Lg6C4oodXB4a6j/0/nF4jWLMxVTx3LH4hljV9o1JKbf3sApv9gUoF4Kwv3dv19iJhjcQLF9gKV8qCeIRC5Dp6cV0XI/IhmAMp5rCOVBqIUxYPWJBZYCatxS3gwVGqQPo/X6OLx35C5N5IVRVYd+D59s1crKTDvkZpGH1zOw=="];
  };

  # Shorthand aliases for various collections of host keys
  servers = concatLists (map (host: machines.${host}) ["HL-1-MRZ-SBC-01"]);
  workstations = concatLists (map (host: machines.${host}) ["HL-1-OZ-PC-01"]);

  all = foldl' (a: b: concatLists [a b]) [users.czichy] (attrValues machines);
in {
  inherit (users) czichy;
  inherit (machines) HL-1-MRZ-SBC-01 HL-1-OZ-PC-01;
  inherit servers workstations all;

  # Additional utilities
  mkGlobal = list: concatLists [list users.czichy];
}
