{
  inputs = {
    # Use git+ssh protocol because it's a private repository
    # See https://discourse.nixos.org/t/nix-flakes-and-private-repositories/12014
    nix-ml-ops.url = "github:Atry/nix-ml-ops";
    nix-ml-ops.inputs.systems.url = "github:nix-systems/default";

    pasd_zip = {
      url = "https://public-vigen-video.oss-cn-shanghai.aliyuncs.com/robin/models/PASD/pasd.zip";
      flake = false;
    };
    stable-diffusion_v1-5-vae = {
      url = "https://modelscope.cn/models/AI-ModelScope/stable-diffusion-v1-5/resolve/master/vae/diffusion_pytorch_model.bin";
      flake = false;
    };
    stable-diffusion_v1-5-text-encoder = {
      url = "https://modelscope.cn/models/AI-ModelScope/stable-diffusion-v1-5/resolve/master/text_encoder/model.safetensors";
      flake = false;
    };

    stable-diffusion_v1-5-pruned-emaonly_safetensors = {
      url = "https://modelscope.cn/models/AI-ModelScope/stable-diffusion-v1-5/resolve/master/v1-5-pruned-emaonly.safetensors";
      flake = false;
    };
    RetinaFace-R50_pth = {
      url = "https://public-vigen-video.oss-cn-shanghai.aliyuncs.com/robin/models/RetinaFace-R50.pth";
      flake = false;
    };
    yolov8n_pt = {
      url = "https://public-vigen-video.oss-cn-shanghai.aliyuncs.com/robin/models/yolov8n.pt";
      flake = false;
    };
    majicmixRealistic_v6_safetensors = {
      url = "https://www.modelscope.cn/models/popatry/majicMIX_realistic_v6/resolve/master/majicmixRealistic_v6.safetensors";
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

          LD_LIBRARY_PATH = lib.mkMerge [
            # `glib` and `libGL` are opencv-python dependencies. They must be added to `$LD_LIBRARY_PATH`, unlike other libraries solved by $LD_AUDIT, because `opencv-python` does not respect $LD_AUDIT.
            "${pkgs.glib.out}/lib"
            "${pkgs.libGL}/lib"
          ];

          nixago.requests = {
            "checkpoints/personalized_models/majicmixRealistic_v6.safetensors" = {
              data = { };
              engine = { data, output, ... }: inputs.majicmixRealistic_v6_safetensors;
            };
            "runs/pasd/checkpoint-100000" = {
              data = { };
              engine = { data, output, ... }: inputs.pasd_zip;
            };
            "checkpoints/stable-diffusion-v1-5/text_encoder/model.safetensors" = {
              data = { };
              engine = { data, output, ... }: inputs.stable-diffusion_v1-5-text-encoder;
            };
            "checkpoints/stable-diffusion-v1-5/vae/diffusion_pytorch_model.bin" = {
              data = { };
              engine = { data, output, ... }: inputs.stable-diffusion_v1-5-vae;
            };
            "checkpoints/stable-diffusion-v1-5/v1-5-pruned-emaonly.safetensors" = {
              data = { };
              engine = { data, output, ... }: inputs.stable-diffusion_v1-5-pruned-emaonly_safetensors;
            };
            "annotator/ckpts/RetinaFace-R50.pth" = {
              data = { };
              engine = { data, output, ... }: inputs.RetinaFace-R50_pth;
            };
            "annotator/ckpts/yolov8n.pt" = {
              data = { };
              engine = { data, output, ... }: inputs.yolov8n_pt;
            };
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

