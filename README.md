# Polygon CDK/zkEVM Blockscout Package
This is a Kurtosis based stack to deploy Blockscout on arbitrary OP based chain.

## Configuration
Be sure to have Kurtosis installed on you computer: https://docs.kurtosis.com/install/

Create a params.yaml with config params
### Required params
- rpc_url: RPC URL
- ws_url: WS URL

### Optional params
- blockscout_public_port: port on which you'll have Blockscout frontend available, 8000 by default
- blockscout_public_ip: public ip if you want to expose blockscout for remote access
- blockscot_backend_port: if you want to expose blockscout to be accessed remotely (you've set blockscout_public_ip), you need to set a port for backend as well

- trace_url: RPC URL with debug endpoints enabled, rpc_url will be used if omitted
- chain_id: l2 chain id, if omitted it will be automatically determined through rpc_url
<!-- - swap_url: URL for swap, will just enable a button link on the top right -->
- l1_explorer: explorer URL for L1 network
- l1_rpc_url: RPC URL for L1
- deployment_suffix: specific for kurtosis, will append this suffic to all services


# Sample screenshots

![Main screen](files/sample-main.png)
![Transaction](files/sample-tx.png)
