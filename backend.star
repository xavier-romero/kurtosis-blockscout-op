def run(plan, cfg):
    host = cfg["DB"]["HOST"]
    port = cfg["DB"]["PORT"]
    db = cfg["DB"]["NAME"]
    user = cfg["DB"]["USER"]
    password = cfg["DB"]["PASSWORD"]

    connection_string = (
        "postgresql://"
        + user
        + ":"
        + password
        + "@"
        + host
        + ":"
        + str(port)
        + "/"
        + db
    )

    rpc_url = cfg["COMMON"]["rpc_url"]
    trace_url = cfg["COMMON"].get("trace_url", rpc_url)
    ws_url = cfg["COMMON"]["ws_url"]
    chain_id = cfg["COMMON"].get("chain_id", None)
    l1_rpc_url = cfg["COMMON"].get("l1_rpc_url", None)
    backend_exposed = cfg["COMMON"].get("backend_exposed", False)
    title = cfg["TITLE"]
    service_port = cfg["PORT"]
    service_port_name = cfg["PORT_NAME"]
    service_name = cfg["NAME"]
    service_image = cfg["IMAGE"]

    env_vars = {
        "PORT": str(service_port),
        "NETWORK": "POE",
        "SUBNETWORK": title,
        "CHAIN_ID": str(chain_id),
        "CHAIN_TYPE": "optimism",
        "COIN": "ETH",
        "ETHEREUM_JSONRPC_VARIANT": "geth",
        "ETHEREUM_JSONRPC_HTTP_URL": rpc_url,
        "ETHEREUM_JSONRPC_TRACE_URL": trace_url,
        "ETHEREUM_JSONRPC_WS_URL": ws_url,
        "ETHEREUM_JSONRPC_HTTP_INSECURE": "true",
        "DATABASE_URL": connection_string,
        "ECTO_USE_SSL": "false",
        "MIX_ENV": "prod",
        "LOGO": "/images/blockscout_logo.svg",
        "LOGO_FOOTER": "/images/blockscout_logo.svg",
        "SUPPORTED_CHAINS": "[]",
        "SHOW_OUTDATED_NETWORK_MODAL": "false",
        "DISABLE_INDEXER": "false",
        "API_V2_ENABLED": "true",
        "BLOCKSCOUT_PROTOCOL": "http",
        "BRIDGED_TOKENS_ENABLED": "true",
        "INDEXER_OPTIMISM_L1_SYSTEM_CONFIG_CONTRACT": cfg["l1_sysconfig_addr"],
        "INDEXER_OPTIMISM_L2_BATCH_GENESIS_BLOCK_NUMBER": "0",
        "INDEXER_OPTIMISM_BLOCK_DURATION": str(cfg["block_time"]),
        "INDEXER_OPTIMISM_L1_PORTAL_CONTRACT": cfg["l1_opportal_addr"],
        "INDEXER_OPTIMISM_L1_BATCH_INBOX": cfg["l1_batchinbox_addr"]
    }
    if l1_rpc_url:
        env_vars["INDEXER_OPTIMISM_L1_RPC"] = l1_rpc_url

    public_ports = {}
    if backend_exposed:
        public_ports = {
            service_port_name: PortSpec(
                service_port, application_protocol="http", wait="1m"
            ),
        }

    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=service_image,
            ports={
                service_port_name: PortSpec(
                    service_port, application_protocol="http", wait="1m"
                ),
            },
            public_ports=public_ports,
            env_vars=env_vars,
            cmd=[
                "/bin/sh",
                "-c",
                'bin/blockscout eval "Elixir.Explorer.ReleaseTasks.create_and_migrate()" && bin/blockscout start',
            ],
        ),
    )
    plan.exec(
        description="""
        Allow 60s for blockscout to start indexing,
        otherwise bs/Stats crashes because it expects to find content on DB
        """,
        service_name=service_name,
        recipe=ExecRecipe(
            command=["/bin/sh", "-c", "sleep 60"],
        ),
    )

    return service, connection_string
