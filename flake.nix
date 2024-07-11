{
  inputs = {
    # Use git+ssh protocol because it's a private repository
    # See https://discourse.nixos.org/t/nix-flakes-and-private-repositories/12014
    nix-ml-ops.url = "github:Atry/nix-ml-ops";
    nix-ml-ops.inputs.systems.url = "github:nix-systems/default";

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
    xsarchitectural_v11_ckpt = {
      url = "https://www.modelscope.cn/models/popatry/XSarchitectural-InteriorDesign-ForXSLora/resolve/master/xsarchitectural_v11.ckpt";
      flake = false;
    };
    toonyou_beta6_safetensors = {
      url = "https://www.modelscope.cn/models/popatry/ToonYou/resolve/master/toonyou_beta6.safetensors";
      flake = false;
    };

  };
  outputs = inputs: inputs.nix-ml-ops.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.nix-ml-ops.flakeModules.devcontainer
      inputs.nix-ml-ops.flakeModules.nixIde
      inputs.nix-ml-ops.flakeModules.nixLd
      inputs.nix-ml-ops.flakeModules.pythonVscode
      inputs.nix-ml-ops.flakeModules.ldFallbackManylinux
      inputs.nix-ml-ops.flakeModules.cuda
      inputs.nix-ml-ops.flakeModules.linkNvidiaDrivers
    ];
    perSystem = { pkgs, config, lib, system, ... }: {
      ml-ops.devcontainer = {

        LD_LIBRARY_PATH = lib.mkMerge [
          # `glib` and `libGL` are opencv-python dependencies. They must be added to `$LD_LIBRARY_PATH`, unlike other libraries solved by $LD_AUDIT, because `opencv-python` does not respect $LD_AUDIT.
          "${pkgs.glib.out}/lib"
          "${pkgs.libGL}/lib"
        ];

        nixago.requests = {
          "checkpoints/personalized_models/toonyou_beta6.safetensors" = {
            data = { };
            engine = { data, output, ... }: inputs.toonyou_beta6_safetensors;
          };
          "checkpoints/personalized_models/xsarchitectural_v11.ckpt" = {
            data = { };
            engine = { data, output, ... }: inputs.xsarchitectural_v11_ckpt;
          };
          "checkpoints/personalized_models/majicmixRealistic_v6.safetensors" = {
            data = { };
            engine = { data, output, ... }: inputs.majicmixRealistic_v6_safetensors;
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

