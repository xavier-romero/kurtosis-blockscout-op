# https://github.com/blockscout/frontend/blob/main/docs/ENVS.md#transaction-interpretation
# https://docs.blockscout.com/for-developers/information-and-settings/env-variables
DB_PORT = 5432
TITLE = "Polygon CDK"
IMAGE_POSTGRES = "postgres:16.2"
# IMAGE_BACKEND = "blockscout/blockscout-optimism:6.9.2"
IMAGE_BACKEND = "blockscout/blockscout-optimism:7.0.2-indexer"
IMAGE_STATS = "ghcr.io/blockscout/stats:v2.2.3"
IMAGE_VISUALIZE = "ghcr.io/blockscout/visualizer:v0.2.1"
IMAGE_FRONTEND = "ghcr.io/blockscout/frontend:v1.36.3"


def get_config(args, db_host=None, get_db_configs=False):
    deployment_suffix = args.get("deployment_suffix", "")
    common_args = args | {
        # "swap_url": args.get("swap_url", "https://app.uniswap.org/#/swap"),
        "l1_explorer": args.get("l1_explorer", "https://etherscan.io/"),
        "l1_rpc_url": args.get("l1_rpc_url", "https://rpc2.sepolia.org/"),
        "backend_exposed": args.get("blockscot_backend_port", False),
    }

    CONFIG = {
        "POSTGRES": {
            "IMAGE": IMAGE_POSTGRES,
            "PORT": DB_PORT,
            "NAME": "master",
            "USER": "master",
            "PASSWORD": "master",
            "SERVICE_NAME": "bs-postgres" + deployment_suffix,
        },
        "BACKEND": {
            "DB": {
                "NAME": "blockscout",
                "USER": "blockscout",
                "PASSWORD": "blockscout",
                "PORT": DB_PORT,
            },
            "IMAGE": IMAGE_BACKEND,
            "NAME": "bs-backend" + deployment_suffix,
            "PORT": args.get("blockscot_backend_port", 4004),
            "PORT_NAME": "backend",
            "TITLE": TITLE,
            "l1_sysconfig_addr": args.get("l1_sysconfig_addr", "0x0"),
            "l1_opportal_addr": args.get("l1_opportal_addr", "0x0"),
            "block_time": args.get("block_time", 2),
            "l1_batchinbox_addr": args.get("l1_batchinbox_addr"),
        },
        "STATS": {
            "DB": {
                "NAME": "stats",
                "USER": "stats",
                "PASSWORD": "stats",
                "PORT": DB_PORT,
            },
            "IMAGE": IMAGE_STATS,
            "NAME": "bs-stats" + deployment_suffix,
            "PORT": 8050,
            "PORT_NAME": "stats",
        },
        "VISUALIZE": {
            "IMAGE": IMAGE_VISUALIZE,
            "NAME": "visualize" + deployment_suffix,
            "PORT": 8050,
            "PORT_NAME": "visualize",
        },
        "FRONTEND": {
            "IMAGE": IMAGE_FRONTEND,
            "NAME": "bs-frontend" + deployment_suffix,
            "PORT": args.get("blockscout_public_port", 8000),
            "PORT_NAME": "frontend",
            "IP": args.get("blockscout_public_ip", None),
            "TITLE": TITLE,
        },
    }

    for k in CONFIG.keys():
        CONFIG[k]["COMMON"] = common_args

    if db_host:
        for k in CONFIG.keys():
            if CONFIG[k].get("DB"):
                CONFIG[k]["DB"]["HOST"] = db_host

    if get_db_configs:
        db_configs = []
        for k in CONFIG.keys():
            if CONFIG[k].get("DB"):
                db_configs.append(
                    {
                        "db": CONFIG[k]["DB"]["NAME"],
                        "user": CONFIG[k]["DB"]["USER"],
                        "password": CONFIG[k]["DB"]["PASSWORD"],
                    }
                )
        return CONFIG, db_configs

    return CONFIG
