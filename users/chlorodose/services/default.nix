{ outputs, ... }:
{
  imports = outputs.lib.scanPath ./.;
}
