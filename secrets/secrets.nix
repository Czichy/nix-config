let
  notashelf = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIABG2T60uEoq4qTZtAZfSBPtlqWs2b4V4O+EptQ6S/ru";

  helios = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8XojSEerAwKwXUPIZASZ5sXPPT7v/26ONQcH9zIFK+";
  enyo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAYCaA6JEnTt2BI6MJn8t2Qc3E45ARZua1VWhQpSPQi";
  hermes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPShBrtrNRNaYUtIWhn0RHDr759mMcfZjqjJRAfCnWU";
in {
  # core system secrets
  "spotify.age".publicKeys = [enyo hermes notashelf];
  "nix-builderKey.age".publicKeys = [enyo helios hermes notashelf];

  # service specific secrets
  "matrix-secret.age".publicKeys = [enyo helios notashelf];
  "nextcloud-secret.age".publicKeys = [enyo helios notashelf];
  "mongodb-secret.age".publicKeys = [enyo helios notashelf];

  # wireguard secrets
  "wg-server.age".publicKeys = [enyo helios notashelf];
  "wg-client.age".publicKeys = [enyo helios hermes notashelf];

  # secrets for specific mailserver accounts
  "mailserver-secret.age".publicKeys = [enyo helios notashelf];
  "mailserver-gitea-secret.age".publicKeys = [enyo helios notashelf];
  "mailserver-vaultwarden-secret.age".publicKeys = [enyo helios notashelf];
  "mailserver-matrix-secret.age".publicKeys = [enyo helios notashelf];
  "mailserver-cloud-secret.age".publicKeys = [enyo helios notashelf];
}
