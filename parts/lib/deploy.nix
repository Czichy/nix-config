{inputs, ...}: let
  mkNode = name: config: let
    inherit (config.meta) system;
    deployLib = inputs.deploy-rs.lib.${system};
  in {
    hostname = "${name}.czichy.czichy.dev";
    sshOpts = ["-p" "30"];
    skipChecks = true;

    # We are currently currently only a single profile system
    profilesOrder = ["system"];
    profiles.system = {
      sshUser = "czichy";
      user = "czichy";
      path = deployLib.activate.nixos config;
    };
  };
in {
  inherit mkNode;
}
