Usually, SSH host key should be generated on first installation
of Termux VM.

If host key is not present in this directory, you can generate
it with following command:

  $ ssh-keygen -t ed25519 -f host_ed25519 -N ''

