{ inputs, ... }:
{
  imports = [ inputs.hci.flakeModule ];

  hercules-ci.flake-update = {
    enable = true;
    baseMerge.enable = true;
    baseMerge.method = "rebase";
    autoMergeMethod = "rebase";
    # Update everynight at midnight
    when = {
      hour = [ 0 ];
      minute = 0;
    };
  };
}
