{
  inputs = {
    # Use git+ssh protocol because it's a private repository
    # See https://discourse.nixos.org/t/nix-flakes-and-private-repositories/12014
    nix-ml-ops.url = "github:Atry/nix-ml-ops";
    nix-ml-ops.inputs.systems.url = "github:nix-systems/default";

    stable-diffusion_v1-5-pruned-emaonly_safetensors = {
      url = "https://modelscope.cn/models/AI-ModelScope/stable-diffusion-v1-5/resolve/master/v1-5-pruned-emaonly.safetensors";
      flake = false;
    };
  };
  outputs = inputs @ { nix-ml-ops, ... }:
    nix-ml-ops.lib.mkFlake { inherit inputs; } {
      imports = [
        nix-ml-ops.flakeModules.devcontainer
        nix-ml-ops.flakeModules.nixIde
        nix-ml-ops.flakeModules.nixLd
        nix-ml-ops.flakeModules.pythonVscode
        nix-ml-ops.flakeModules.ldFallbackManylinux
      ];
      perSystem = { pkgs, config, lib, system, ... }: {
        ml-ops.devcontainer = {
          nixago.requests."checkpoints/stable-diffusion-v1-5/v1-5-pruned-emaonly.safetensors" = {
            data = { };
            engine = { data, output, ... }: inputs.stable-diffusion_v1-5-pruned-emaonly_safetensors;
          };
          devenvShellModule = {
            languages = {
              python = {
                enable = true;
                venv = {
                  enable = true;
                  requirements = builtins.readFile ./requirements.txt;
                };
              };
            };
          };
        };

      };
    };
}
