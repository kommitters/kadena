# Kadena.ex

![Stability Badge](https://img.shields.io/badge/stability-alpha-f4d03f.svg?style=for-the-badge)
![Build Badge](https://img.shields.io/github/actions/workflow/status/kommitters/kadena.ex/ci.yml?branch=main&style=for-the-badge)
[![Coverage Status](https://img.shields.io/coveralls/github/kommitters/kadena.ex?style=for-the-badge)](https://coveralls.io/github/kommitters/kadena.ex)
[![Version Badge](https://img.shields.io/hexpm/v/kadena?style=for-the-badge)](https://hexdocs.pm/kadena)
![Downloads Badge](https://img.shields.io/hexpm/dt/kadena?style=for-the-badge)
[![License badge](https://img.shields.io/hexpm/l/kadena?style=for-the-badge)](https://github.com/kommitters/kadena.ex/blob/main/LICENSE)
[![OpenSSF Best Practices](https://img.shields.io/cii/summary/6474?label=openssf%20best%20practices&style=for-the-badge)](https://bestpractices.coreinfrastructure.org/projects/6474)
[![OpenSSF Scorecard](https://img.shields.io/ossf-scorecard/github.com/kommitters/kadena.ex?label=openssf%20scorecard&style=for-the-badge)](https://api.securityscorecards.dev/projects/github.com/kommitters/kadena.ex)

**Kadena.ex** is an open source library for Elixir that allows developers to interact with Kadena Chainweb.

## What can you do with Kadena.ex?

- Build PACT commands for transactions.
- Implement the cryptography required by the network.
- Send, test and update smart contracts.
- Interact with Chainweb endpoints.
  - Pact API: `listen, local, poll, send, spv`.
  - P2P API: `Cut, Block Hashes, Block Headers, Block Payload, Mempool, Peer`.

## Installation

Add `kadena` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kadena, "~> 0.19.1"}
  ]
end
```

## Configuration

The default HTTP Client is `:hackney`. Options can be passed to `:hackney` via configuration parameters.
```elixir
config :kadena, hackney_opts: [{:connect_timeout, 1000}, {:recv_timeout, 5000}]
```

### Custom HTTP Client
`kadena.ex` allows you to use the HTTP client of your choice. See [**Kadena.Chainweb.Client.Spec**][http_client_spec] for details.

```elixir
config :kadena, :http_client_impl, YourApp.CustomClientImpl
```

### Custom JSON library
Following the same approach as the HTTP client, the JSON parsing library can also be configured. Defaults to [`Jason`][jason_url].

```elixir
config :kadena, :json_library, YourApp.CustomJSONLibrary
```

## Keypairs
Curve25519 keypair of (PUBLIC,SECRET) match. Key values are base-16 strings of length 32.

### Generate a KeyPair

```elixir
alias Kadena.Cryptography.KeyPair

# generate a random keypair
{:ok, keypair} = KeyPair.generate()

{:ok,
 %Kadena.Types.KeyPair{
   clist: nil,
   pub_key: "37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9",
   secret_key: "e53faf1774d30e7cec2878d2e4a617c34045f53f0579eb05e127a7808aac229d"
 }}
```

### Derive a keyPair from a secret key
```elixir
{:ok, keypair} = KeyPair.from_secret_key("e53faf1774d30e7cec2878d2e4a617c34045f53f0579eb05e127a7808aac229d")

{:ok,
 %Kadena.Types.KeyPair{
   clist: nil,
   pub_key: "37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9",
   secret_key: "e53faf1774d30e7cec2878d2e4a617c34045f53f0579eb05e127a7808aac229d"
 }}
```

### Adding capabilities to a KeyPair

```elixir
alias Kadena.Cryptography.KeyPair
alias Kadena.Types.Cap

{:ok, keypair} = KeyPair.from_secret_key("e53faf1774d30e7cec2878d2e4a617c34045f53f0579eb05e127a7808aac229d")

clist = [
  Cap.new(name: "coin.GAS", args: [keypair.pub_key])
]

keypair_with_caps = Kadena.Types.KeyPair.add_caps(keypair, clist)

%Kadena.Types.KeyPair{
  clist: [
    %Kadena.Types.Cap{
      args: [
        %Kadena.Types.PactValue{
          literal: "37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9"
        }
      ],
      name: "coin.GAS"
    }
  ],
  pub_key: "37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9",
  secret_key: "e53faf1774d30e7cec2878d2e4a617c34045f53f0579eb05e127a7808aac229d"
}
```

## PACT Commands

`kadena.ex` allows the construction of **execution** and **continuation** commands in a semantic way for developers.

```elixir
alias Kadena.Cryptography.KeyPair
alias Kadena.Types.Command
alias Kadena.Pact

{:ok, keypair} = KeyPair.generate()

code = "(+ 1 2)"

{:ok, %Command{} = command} =
  Pact.ExecCommand.new()
  |> Pact.ExecCommand.set_code(code)
  |> Pact.ExecCommand.add_keypair(keypair)
  |> Pact.ExecCommand.build()
```

### Attributes

#### NetworkID
Backend-specific identifier of target network. Allowed values: `:testnet04` `:mainnet01` `:development`.

```elixir
alias Kadena.Pact

network_id = :testnet04

Pact.ExecCommand.new() |> Pact.ExecCommand.set_network(network_id)
```

#### Code
Executable PACT code.

```elixir
alias Kadena.Pact

code = "(+ 1 2)"

Pact.ExecCommand.new() |> Pact.ExecCommand.set_code(code)
```

#### Metadata
Public metadata for Chainweb.

```elixir
alias Kadena.Pact

metadata = Kadena.Types.MetaData.new(
    creation_time: 1_667_249_173,
    ttl: 28_800,
    gas_limit: 1000,
    gas_price: 0.01,
    sender: "k:37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9",
    chain_id: "0"
  )

Pact.ExecCommand.new() |> Pact.ExecCommand.set_metadata(metadata)
```

#### Nonce
An arbitrary user-supplied value. Defaults to current timestamp.

```elixir
alias Kadena.Pact

nonce = "2023-01-01 00:00:00.000000 UTC"

Pact.ExecCommand.new() |> Pact.ExecCommand.set_nonce(data)
```

#### EnvData
Environment transaction data.

```elixir
alias Kadena.Pact

env_data = %{
    accounts_admin_keyset: [
      "ba54b224d1924dd98403f5c751abdd10de6cd81b0121800bf7bdbdcfaec7388d"
    ]
  }

Pact.ExecCommand.new() |> Pact.ExecCommand.set_data(data)
```

#### KeyPairs
List of KeyPairs for signing.

```elixir
alias Kadena.Pact
alias Kadena.Cryptography.KeyPair

{:ok, keypair1} = KeyPair.generate()
{:ok, keypair2} = KeyPair.generate()

# add a list of keypairs
Pact.ExecCommand.new() |> Pact.ExecCommand.add_keypairs([keypair1, keypair2])

# add a single keypair
Pact.ExecCommand.new() |> Pact.ExecCommand.add_keypair(keypair1)
```

#### Signers
List of signers for detached signatures.

```elixir
alias Kadena.Pact

signer1 = Kadena.Types.Signer.new(pub_key: "37e60c00779cacaef1f0a8697387a5945ef3cb82963980db486dc26ec5f424d9")
signer2 = Kadena.Types.Signer.new(pub_key: "8567032f1fe8b99c657338cd46480d0ee1a86985626b16374099d8d406e4d313")

# add a list of signers
Pact.ExecCommand.new() |> Pact.ExecCommand.add_signers([signer1, signer2])

# add a single signer
Pact.ExecCommand.new() |> Pact.ExecCommand.add_signer(signer1)
```

#### Step (Continuation command)

An integer value for the multi-step transaction.

```elixir
alias Kadena.Pact

step = 1

Pact.ContCommand.new() |> Pact.ContCommand.set_step(step)
```

#### Proof (Continuation command)

A SPV proof, required for cross-chain transfer.

```elixir
alias Kadena.Pact

proof = "proof"

Pact.ContCommand.new() |> Pact.ContCommand.set_proof(proof)
```

#### Rollback (Continuation command)

A Boolean that indicates if the continuation is:

- rollback `true`
- cancel `false`

```elixir
alias Kadena.Pact

rollback = true

Pact.ContCommand.new() |> Pact.ContCommand.set_rollback(rollback)
```

#### PactTxHash (Continuation command)

Continuation transaction hash.

```elixir
alias Kadena.Pact

pact_tx_hash = "yxM0umrtdcvSUZDc_GSjwadH6ELYFCjOqI59Jzqapi4"

Pact.ContCommand.new() |> Pact.ContCommand.set_pact_tx_hash(pact_tx_hash)
```

### Building an Execution Command

There are two ways to create an ExecCommand.

#### Using [attributes](#attributes) structures

```elixir
alias Kadena.Cryptography
alias Kadena.Pact

# set the command attributes
{:ok, raw_keypair} = Cryptography.KeyPair.from_secret_key("99f7e1e8f2f334ae8374aa28bebdb997271a0e0a5e92c80be9609684a3d6f0d4")

caps = [
  Kadena.Types.Cap.new(name: "coin.GAS", args: [raw_keypair.pub_key])
]


keypair = Kadena.Types.KeyPair.add_caps(raw_keypair, caps)

network_id = :testnet04

code = "(+ 1 2)"

metadata = Kadena.Types.MetaData.new(
    creation_time: 1_667_249_173,
    ttl: 28_800,
    gas_limit: 2500,
    gas_price: 0.01,
    sender: "k:#{keypair.pub_key}",
    chain_id: "0"
  )

nonce = "2023-01-01 00:00:00.000000 UTC"

env_data = %{accounts_admin_keyset: [keypair.pub_key]}

# build the command
{:ok, %Kadena.Types.Command{} = command} =
  Pact.ExecCommand.new()
  |> Pact.ExecCommand.set_network(network_id)
  |> Pact.ExecCommand.set_code(code)
  |> Pact.ExecCommand.set_nonce(nonce)
  |> Pact.ExecCommand.set_data(env_data)
  |> Pact.ExecCommand.set_metadata(metadata)
  |> Pact.ExecCommand.add_keypair(keypair)
  |> Pact.ExecCommand.build()

{:ok,
 %Kadena.Types.Command{
   cmd:
     "{\"meta\":{\"chainId\":\"0\",\"creationTime\":1667249173,\"gasLimit\":2500,\"gasPrice\":0.01,\"sender\":\"k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"ttl\":28800},\"networkId\":\"testnet04\",\"nonce\":\"2023-01-01 00:00:00.000000 UTC\",\"payload\":{\"exec\":{\"code\":\"(+ 1 2)\",\"data\":{\"accounts_admin_keyset\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"]}}},\"signers\":[{\"addr\":null,\"clist\":[{\"args\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"],\"name\":\"coin.GAS\"}],\"pubKey\":\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"scheme\":\"ED25519\"}]}",
   hash: %Kadena.Types.PactTransactionHash{
     hash: "ZOsqP9Wkfj5NnY9WS_XMnO9KfYv0GvK_8QMPTX6BfaA"
   },
   sigs: [
     %Kadena.Types.Signature{
       sig:
         "5b0635c2376949103d8ce8243a1fd34a1a8964900d69eebb1ff4d38ffde437a317f887f864fa9c1b27a97e8d9e57eef8dd58b054edf30b4e6fe89d0208290f02"
     }
   ]
 }}
```

#### From a `YAML` file

YAML struct:

- `networkId`: [NetworkID](#networkid) value.
- `code`: there are two ways to set the code from the `YAML` file:
  - `code`: [Code](#code) value.
  - `codeFile`: The name of a `pact` file in the same directory as the `YAML` file. For example, `code.pact`.
- `data`: there are two ways to set the data from the `YAML` file:
  - `data`: [EnvData](#envdata) value.
  - `dataFile`: The name of a `json` file in the same directory as the `YAML` file. For example, `data.json`.
- `nonce`:  [Nonce](#nonce) value.
- `publicMeta`: [Metadata](#metadata) value.
- `keyPairs`: [KeyPairs](#keypairs) values.
- `signers`: [Signers](#signers) values.

The scheme below shows how to set the different values of an `ExecCommand`

```YAML
networkId:
code/codeFile:
data/dataFile:
nonce: 
publicMeta:
  creationTime: 
  chainId: 
  gasLimit: 
  gasPrice: 
  ttl:
  sender: 
keyPairs:
  - public: 
    secret: 
signers:
  - publicKey: 
    scheme: 
    addr: 
    capsList:
      - name: 
        args:
          - 
```
**Example**

YAML file: 
```YAML
networkId: :testnet04 
code: "(+ 1 2)"
data:
  accounts_admin_keyset:
    - 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
nonce: 2023-01-01 00:00:00.000000 UTC
publicMeta:
  creationTime: 1667249173
  chainId: "0"
  gasLimit: 2500
  gasPrice: 0.01
  ttl: 28800
  sender: k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
keyPairs:
  - public: 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
    secret: 99f7e1e8f2f334ae8374aa28bebdb997271a0e0a5e92c80be9609684a3d6f0d4
    capsList: 
      name: coin.GAS
      args: 
        - 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7

```

```elixir
alias Kadena.Pact.ExecCommand

"~/example.yaml"
|> ExecCommand.from_yaml()
|> ExecCommand.build()

{:ok,
 %Kadena.Types.Command{
   cmd:
     "{\"meta\":{\"chainId\":\"0\",\"creationTime\":1667249173,\"gasLimit\":2500,\"gasPrice\":0.01,\"sender\":\"k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"ttl\":28800},\"networkId\":\"testnet04\",\"nonce\":\"2023-01-01 00:00:00.000000 UTC\",\"payload\":{\"exec\":{\"code\":\"(+ 1 2)\",\"data\":{\"accounts_admin_keyset\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"]}}},\"signers\":[{\"addr\":null,\"clist\":[{\"args\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"],\"name\":\"coin.GAS\"}],\"pubKey\":\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"scheme\":\"ED25519\"}]}",
   hash: %Kadena.Types.PactTransactionHash{
     hash: "ZOsqP9Wkfj5NnY9WS_XMnO9KfYv0GvK_8QMPTX6BfaA"
   },
   sigs: [
     %Kadena.Types.Signature{
       sig:
         "5b0635c2376949103d8ce8243a1fd34a1a8964900d69eebb1ff4d38ffde437a317f887f864fa9c1b27a97e8d9e57eef8dd58b054edf30b4e6fe89d0208290f02"
     }
   ]
 }}

```

### Building a Continuation Command

There are two ways to create a ContCommand.

#### Using [attributes](#attributes) structures

```elixir
alias Kadena.Cryptography
alias Kadena.Pact

# set the command attributes
{:ok, raw_keypair} = Cryptography.KeyPair.from_secret_key("99f7e1e8f2f334ae8374aa28bebdb997271a0e0a5e92c80be9609684a3d6f0d4")

caps = [
  Kadena.Types.Cap.new(name: "coin.GAS", args: [raw_keypair.pub_key])
]

keypair = Kadena.Types.KeyPair.add_caps(raw_keypair, caps)

network_id = :testnet04

metadata = Kadena.Types.MetaData.new(
    creation_time: 1_667_249_173,
    ttl: 28_800,
    gas_limit: 2500,
    gas_price: 0.01,
    sender: "k:#{keypair.pub_key}",
    chain_id: "0"
  )

nonce = "2023-01-01 00:00:00.000000 UTC"

env_data = %{accounts_admin_keyset: [keypair.pub_key]}

pact_tx_hash = "yxM0umrtdcvSUZDc_GSjwadH6ELYFCjOqI59Jzqapi4"

step = 1

rollback = true

# build the command
{:ok, %Kadena.Types.Command{} = command} =
  Pact.ContCommand.new()
  |> Pact.ContCommand.set_network(network_id)
  |> Pact.ContCommand.set_data(env_data)
  |> Pact.ContCommand.set_nonce(nonce)
  |> Pact.ContCommand.set_metadata(metadata)
  |> Pact.ContCommand.add_keypair(keypair)
  |> Pact.ContCommand.set_pact_tx_hash(pact_tx_hash)
  |> Pact.ContCommand.set_step(step)
  |> Pact.ContCommand.set_rollback(rollback)
  |> Pact.ContCommand.build()

{:ok,
 %Kadena.Types.Command{
   cmd:
     "{\"meta\":{\"chainId\":\"0\",\"creationTime\":1667249173,\"gasLimit\":2500,\"gasPrice\":0.01,\"sender\":\"k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"ttl\":28800},\"networkId\":\"testnet04\",\"nonce\":\"2023-01-01 00:00:00.000000 UTC\",\"payload\":{\"cont\":{\"data\":{\"accounts_admin_keyset\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"]},\"pactId\":\"yxM0umrtdcvSUZDc_GSjwadH6ELYFCjOqI59Jzqapi4\",\"proof\":null,\"rollback\":true,\"step\":1}},\"signers\":[{\"addr\":null,\"clist\":[{\"args\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"],\"name\":\"coin.GAS\"}],\"pubKey\":\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"scheme\":\"ED25519\"}]}",
   hash: %Kadena.Types.PactTransactionHash{
     hash: "DIMUpcB9NahL3746TTm1A8Wrr-JRVCT5Rk0rPdxZItg"
   },
   sigs: [
     %Kadena.Types.Signature{
       sig:
         "98de12eda675334c7fddb6ca453017bf2df5af928c2c0763f8748b950f81b7b075f74fc2294f6a16099aa51955a035889767f048a76f7a272eaf639140dbd20a"
     }
   ]
 }}
```

#### From a `YAML` file

YAML struct:

- `networkId`: [NetworkID](#networkid) value.
- `data`: there are two ways to set the data from the `YAML` file:
  - `data`: [EnvData](#envdata) value.
  - `dataFile`: The name of a `json` file in the same directory as the `YAML` file. For example, `data.json`. 
- `nonce`:  [Nonce](#nonce) value.
- `publicMeta`: [Metadata](#metadata) value.
- `keyPairs`: [KeyPairs](#keypairs) values.
- `signers`: [Signers](#signers) values.
- `pactTxHash`: [PactTxHash](#pacttxhash-continuation-command) value.
- `rollback`: [Rollback](#rollback-continuation-command) value.
- `Step`: [Step](#step-continuation-command) value.
- `proof`: [Proof](#proof-continuation-command) value.


The scheme below shows how to set the different values of a `ContCommand`

```YAML
networkId:
data/dataFile:
nonce: 
publicMeta:
  creationTime: 
  chainId: 
  gasLimit: 
  gasPrice: 
  ttl:
  sender: 
keyPairs:
  - public: 
    secret: 
signers:
  - publicKey: 
    scheme: 
    addr: 
    capsList:
      - name: 
        args:
          - 
pactTxHash: 
step: 
rollback: 
proof:

```
**Example**

YAML file: 
```YAML
networkId: :testnet04
data:
  accounts_admin_keyset:
    - 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
nonce: 2023-01-01 00:00:00.000000 UTC
publicMeta:
  creationTime: 1667249173
  chainId: "0"
  gasLimit: 2500
  gasPrice: 0.01
  ttl: 28800
  sender: k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
keyPairs:
  - public: 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
    secret: 99f7e1e8f2f334ae8374aa28bebdb997271a0e0a5e92c80be9609684a3d6f0d4
    capsList: 
      name: coin.GAS
      args: 
        - 6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7
pactTxHash: yxM0umrtdcvSUZDc_GSjwadH6ELYFCjOqI59Jzqapi4
step: 1
rollback: true

```

```elixir
alias Kadena.Pact.ContCommand

"~/example.yaml"
|> ContCommand.from_yaml()
|> ContCommand.build()

{:ok,
 %Kadena.Types.Command{
   cmd:
     "{\"meta\":{\"chainId\":\"0\",\"creationTime\":1667249173,\"gasLimit\":2500,\"gasPrice\":0.01,\"sender\":\"k:6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"ttl\":28800},\"networkId\":\"testnet04\",\"nonce\":\"2023-01-01 00:00:00.000000 UTC\",\"payload\":{\"cont\":{\"data\":{\"accounts_admin_keyset\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"]},\"pactId\":\"\",\"proof\":null,\"rollback\":true,\"step\":0}},\"signers\":[{\"addr\":null,\"clist\":[{\"args\":[\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\"],\"name\":\"coin.GAS\"}],\"pubKey\":\"6ffea3fabe4e7fe6a89f88fc6d662c764ed1359fbc03a28afdac3935415347d7\",\"scheme\":\"ED25519\"}]}",
   hash: %Kadena.Types.PactTransactionHash{
     hash: "psIXOGGneMAV1Ie3zx5O1VWMFueFZrShvaBx4YOCkjQ"
   },
   sigs: [
     %Kadena.Types.Signature{
       sig:
         "1ae6e796bbf8e1ddb005945508ac6fd13cc6435c4f63609cff299114865fd13879b8b5bcad13383ae377acc10411e49e745397320a2ba5bf9d1370cafbf90a06"
     }
   ]
 }}

```

## Chainweb Pact API

Interaction with [Chainweb Pact API][chainweb_pact_api_doc] is done through the [**Kadena.Chainweb.Pact**][chainweb_pact_api] module using simple functions to access endpoints.

### Send endpoint

Retrieves the request keys of the Pact transactions sent to the network.

```elixir
Kadena.Chainweb.Pact.send(cmds, network_opts \\ [network_id: :testnet04, chain_id: 0])
```

**Parameters**

- `cmds`: List of [PACT commands](#pact-commands).
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb
alias Kadena.Cryptography
alias Kadena.Pact

{:ok, keypair} =
  Cryptography.KeyPair.from_secret_key(
    "28834b7a0d6d1f84ae2c2efcb5b1de28122e07e2e4caad04a32988a3c79c547c"
  )

network_id = :testnet04

metadata =
  Kadena.Types.MetaData.new(
    creation_time: 1_671_462_208,
    ttl: 28_800,
    gas_limit: 1000,
    gas_price: 0.000001,
    sender: "k:#{keypair.pub_key}",
    chain_id: "1"
  )

code = "(+ 1 2)"

{:ok, cmd1} =
  Pact.ExecCommand.new()
  |> Pact.ExecCommand.set_network(network_id)
  |> Pact.ExecCommand.set_code(code)
  |> Pact.ExecCommand.set_metadata(metadata)
  |> Pact.ExecCommand.add_keypair(keypair)
  |> Pact.ExecCommand.build()

code = "(+ 2 2)"

{:ok, cmd2} =
  Pact.ExecCommand.new()
  |> Pact.ExecCommand.set_network(network_id)
  |> Pact.ExecCommand.set_code(code)
  |> Pact.ExecCommand.set_metadata(metadata)
  |> Pact.ExecCommand.add_keypair(keypair)
  |> Pact.ExecCommand.build()

cmds = [cmd1, cmd2]

Chainweb.Pact.send(cmds, network_id: :testnet04, chain_id: 1)

{:ok,
 %Kadena.Chainweb.Pact.SendResponse{
   request_keys: [
     "rz03l9cXJTLNzBJoTitum7yyBq3amdAqM5sopw5gZyQ",
     "dS3UDAnJBKwReOFiyNU6qUwuclvXKDMYSPT6YDCkrJY"
   ]
 }}
```

### Local endpoint

Executes a single command on the local server and retrieves the transaction result. Useful with code that queries from blockchain. It does not impact the blockchain when returning transaction results.

```elixir
Kadena.Chainweb.Pact.local(cmd, network_opts \\ [network_id: :testnet04, chain_id: 0])
```

**Parameters**

- `cmd`: [PACT command](#pact-commands).
- `network_opts`: Network options. Keyword list with:

  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb
alias Kadena.Cryptography
alias Kadena.Pact

{:ok, keypair} =
  Cryptography.KeyPair.from_secret_key(
    "28834b7a0d6d1f84ae2c2efcb5b1de28122e07e2e4caad04a32988a3c79c547c"
  )

metadata =
  Kadena.Types.MetaData.new(
    creation_time: 1_671_462_208,
    ttl: 28_800,
    gas_limit: 1000,
    gas_price: 0.000001,
    sender: "k:#{keypair.pub_key}",
    chain_id: "1"
  )

code = "(+ 1 2)"

{:ok, cmd} =
  Pact.ExecCommand.new()
  |> Pact.ExecCommand.set_code(code)
  |> Pact.ExecCommand.set_metadata(metadata)
  |> Pact.ExecCommand.add_keypair(keypair)
  |> Pact.ExecCommand.build()

Chainweb.Pact.local(cmd, network_id: :testnet04, chain_id: 1)

{:ok,
 %Kadena.Chainweb.Pact.LocalResponse{
   continuation: nil,
   events: nil,
   gas: 5,
   logs: "wsATyGqckuIvlm89hhd2j4t6RMkCrcwJe_oeCYr7Th8",
   meta_data: %{
     block_height: 2_833_149,
     block_time: 1_671_577_178_603_103,
     prev_block_hash: "7aURwajZ0pBMGEKmOUJ9oLq9MK7QiZeiDPGPb0cXs5c",
     public_meta: %{
       chain_id: "1",
       creation_time: 1_671_462_208,
       gas_limit: 1000,
       gas_price: 1.0e-6,
       sender: "k:d1a361d721cf81dbc21f676e6897f7e7a336671c0d5d25f87c10933cac6d8cf7",
       ttl: 28800
     }
   },
   req_key: "8qnotzzhbfe_SSmZcDVQGDpALjQjYqzYYrHc6D-2D_g",
   result: %{data: 3, status: "success"},
   tx_id: nil
 }}
```
### Poll endpoint

Retrieves one or more transaction results per request key.

```elixir
Kadena.Chainweb.Pact.poll(request_keys, network_opts \\ [network_id: :testnet04, chain_id: 0])
```

**Parameters**

- `request_keys`: List of strings. A request key is the unique id of a Pact transaction consisting of its hash, it is obtained from submitting a command via the  [Send endpoint](#send-endpoint).
- `network_opts`: Network options. Keyword list with:

  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb

request_keys = [
  "VB4ZKobzuo5Cwv5LT9kWKg-34u7KZ0Oo84jnIiujTGc",
  "gyShUgtFBk5xDoiBoLURbU_5vUG0benKroNDRhz8wqA"
]

Chainweb.Pact.poll(request_keys, network_id: :testnet04, chain_id: 1)

{:ok,
 %Kadena.Chainweb.Pact.PollResponse{
   results: [
     %Kadena.Chainweb.Pact.CommandResult{
       continuation: nil,
       events: [
         %{
           module: %{name: "coin", namespace: nil},
           module_hash: "rE7DU8jlQL9x_MPYuniZJf5ICBTAEHAIFQCB4blofP4",
           name: "TRANSFER",
           params: [
             "k:d1a361d721cf81dbc21f676e6897f7e7a336671c0d5d25f87c10933cac6d8cf7",
             "k:db776793be0fcf8e76c75bdb35a36e67f298111dc6145c66693b0133192e2616",
             2.33e-4
           ]
         }
       ],
       gas: 233,
       logs: "3I4ueiuyFy2m_z6PHpOe9yqXIt9tfDjMoUlPnqg_jas",
       meta_data: %{
         block_hash: "Z9fszmqYV7s_rLyvvdAw5nbLqdMIj-_P4lPGFMLRy3M",
         block_height: 2_829_780,
         block_time: 1_671_476_220_495_690,
         prev_block_hash: "9LKeJBo1REDwbVUYjxKKvbuHN4kFRDmjxEqatUUPu8g"
       },
       req_key: "gyShUgtFBk5xDoiBoLURbU_5vUG0benKroNDRhz8wqA",
       result: %{data: 4, status: "success"},
       tx_id: 4_272_497
     },
     %Kadena.Chainweb.Pact.CommandResult{
       continuation: nil,
       events: [
         %{
           module: %{name: "coin", namespace: nil},
           module_hash: "rE7DU8jlQL9x_MPYuniZJf5ICBTAEHAIFQCB4blofP4",
           name: "TRANSFER",
           params: [
             "k:d1a361d721cf81dbc21f676e6897f7e7a336671c0d5d25f87c10933cac6d8cf7",
             "k:db776793be0fcf8e76c75bdb35a36e67f298111dc6145c66693b0133192e2616",
             2.33e-4
           ]
         }
       ],
       gas: 233,
       logs: "P3CDVUbCSSsXukPztkmLjJL7tsxNNIuPHKyhGMD_0wE",
       meta_data: %{
         block_hash: "Z9fszmqYV7s_rLyvvdAw5nbLqdMIj-_P4lPGFMLRy3M",
         block_height: 2_829_780,
         block_time: 1_671_476_220_495_690,
         prev_block_hash: "9LKeJBo1REDwbVUYjxKKvbuHN4kFRDmjxEqatUUPu8g"
       },
       req_key: "VB4ZKobzuo5Cwv5LT9kWKg-34u7KZ0Oo84jnIiujTGc",
       result: %{data: 3, status: "success"},
       tx_id: 4_272_500
     }
   ]
 }}
```

### Listen endpoint

Retrieves the transaction result of the given request key.

```elixir
Kadena.Chainweb.Pact.listen(request_key, network_opts \\ [network_id: :testnet04, chain_id: 0])
```

**Parameters**

- `request_key`: String value. A request key is the unique id of a Pact transaction consisting of its hash, it is obtained from submitting a command via the [Send endpoint](#send-endpoint).
- `network_opts`: Network options. Keyword list with:

  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb

request_key = "VB4ZKobzuo5Cwv5LT9kWKg-34u7KZ0Oo84jnIiujTGc"

Chainweb.Pact.listen(request_key, network_id: :testnet04, chain_id: 1)

{:ok,
 %Kadena.Chainweb.Pact.ListenResponse{
   continuation: nil,
   events: [
     %{
       module: %{name: "coin", namespace: nil},
       module_hash: "rE7DU8jlQL9x_MPYuniZJf5ICBTAEHAIFQCB4blofP4",
       name: "TRANSFER",
       params: [
         "k:d1a361d721cf81dbc21f676e6897f7e7a336671c0d5d25f87c10933cac6d8cf7",
         "k:db776793be0fcf8e76c75bdb35a36e67f298111dc6145c66693b0133192e2616",
         2.33e-4
       ]
     }
   ],
   gas: 233,
   logs: "P3CDVUbCSSsXukPztkmLjJL7tsxNNIuPHKyhGMD_0wE",
   meta_data: %{
     block_hash: "Z9fszmqYV7s_rLyvvdAw5nbLqdMIj-_P4lPGFMLRy3M",
     block_height: 2_829_780,
     block_time: 1_671_476_220_495_690,
     prev_block_hash: "9LKeJBo1REDwbVUYjxKKvbuHN4kFRDmjxEqatUUPu8g"
   },
   req_key: "VB4ZKobzuo5Cwv5LT9kWKg-34u7KZ0Oo84jnIiujTGc",
   result: %{data: 3, status: "success"},
   tx_id: 4_272_500
 }}
```

### SPV endpoint

Retrieves a SPV proof of a cross chain transaction. Request must be sent to the chain where the transaction is initiated.

```elixir
Kadena.Chainweb.Pact.spv(payload, network_opts \\ [network_id: :testnet04, chain_id: 0])
```

**Parameters**

- `payload`: Keyword list with:

  - `request_key` (required): String value. Request Key of an initiated cross chain transaction at the source chain.

  - `target_chain_id` (required): String-encoded integer from 0 to 19. Target chain id of the cross chain transaction.


- `network_opts`: Network options. Keyword list with:

  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb

payload = [request_key: "VB4ZKobzuo5Cwv5LT9kWKg-34u7KZ0Oo84jnIiujTGc", target_chain_id: "2"]

Chainweb.Pact.spv(payload, network_id: :testnet04, chain_id: 1)

{:ok,
 %Kadena.Chainweb.Pact.SPVResponse{
   proof:
     "eyJjaGFpbiI6Miwib2JqZWN0IjoiQUFBQUVBQUFBQUFBQUFBQ0FBRm5kSVUwc0tpRHJvUWQ0LWJxbHA4dThxd3BpdXRvdXVFXzFxY1JteUNsQUtBN1BRSGxRcTlPMmpQT0E3VlI5bXhVZm4yVDhGdjcxTFFfVTM3eEw5Q3hBYTdkN0lnWUFUZUgxLWNEb3RJbnVyRFZMX1FjYzJyTzFtR3BvY21TcWlfeUFiR1JrXzVnT0Jka0JXVWVLS0lnRHN1YWlmbGt4S0R0alJfSndSSmxPd2w3QUZ0ZWxrZXNWVkZ6aUMyUXgwUFczSmJPY3pQOFVINjRteVNWTTNHUGhxUE5BYWdtUEpTenRsUlNSOTJhNUl5d1dZYVlmREVweUljLWNwSG9VSDdSWTBWZkFGVmVlZG1qbUFZS1l4RTdoS1VZa0gtLWN0dkFWbUFuQWlPYm1xUmFsUnlfQUt0RWJnOU9BSzNyTUZfM01STUpkODFpZmJCdnBHT2Jxckk5bXZEU1U0cEpBYjMtcTdXYU9hTWVVVk9XdlI4NUxLQW9qbFdXLVRmeVdrRXJMLXBreGZtNkFPOURadkNIOExiZkwzYlFXOWRKbUN0VHRteXI3N3pNZGxNaGVvb1k5OHNDQWRKcF9rN0hNUXJpLUtSTEFWeHJkT1dCOEt4dk13UldsaDNHQTRFa2ZFTnhBSW83N29OWGlKb3hLOUdqWFVwcGJXWnhDY1Q5TVJwQ0NHTURsVndmdkpaREFOMlpWZW8wSUxVOXd1XzNlOTRLUUEtUk9SNk1LUFFBeWJ4VHczUzVLbFg4QVg2aFhmODljMGpLRzBqeUQ0cVZxR2hhaGp0ZjNsRGdaekdPbEhDY3FNd2NBQ01yVTEyM3VHbnRUTnpUVVljREF5bTZnU1c2MUxWeFp5SjZxMjBoQzRSR0FPQUxJbGVBVy1tYVlBdXVkN08xeGhQbVFlcFg0MzhrWXJCOVd1Z3ZRUXg4Iiwic3ViamVjdCI6eyJpbnB1dCI6IkFCUjdJbWRoY3lJNk1qTXpMQ0p5WlhOMWJIUWlPbnNpYzNSaGRIVnpJam9pYzNWalkyVnpjeUlzSW1SaGRHRWlPak45TENKeVpYRkxaWGtpT2lKV1FqUmFTMjlpZW5Wdk5VTjNkalZNVkRsclYwdG5MVE0wZFRkTFdqQlBiemcwYW01SmFYVnFWRWRqSWl3aWJHOW5jeUk2SWxBelEwUldWV0pEVTFOeldIVnJVSHAwYTIxTWFrcE1OM1J6ZUU1T1NYVlFTRXQ1YUVkTlJGOHdkMFVpTENKbGRtVnVkSE1pT2x0N0luQmhjbUZ0Y3lJNld5SnJPbVF4WVRNMk1XUTNNakZqWmpneFpHSmpNakZtTmpjMlpUWTRPVGRtTjJVM1lUTXpOalkzTVdNd1pEVmtNalZtT0Rkak1UQTVNek5qWVdNMlpEaGpaamNpTENKck9tUmlOemMyTnprelltVXdabU5tT0dVM05tTTNOV0prWWpNMVlUTTJaVFkzWmpJNU9ERXhNV1JqTmpFME5XTTJOalk1TTJJd01UTXpNVGt5WlRJMk1UWWlMREl1TXpObExUUmRMQ0p1WVcxbElqb2lWRkpCVGxOR1JWSWlMQ0p0YjJSMWJHVWlPbnNpYm1GdFpYTndZV05sSWpwdWRXeHNMQ0p1WVcxbElqb2lZMjlwYmlKOUxDSnRiMlIxYkdWSVlYTm9Jam9pY2tVM1JGVTRhbXhSVERsNFgwMVFXWFZ1YVZwS1pqVkpRMEpVUVVWSVFVbEdVVU5DTkdKc2IyWlFOQ0o5WFN3aWJXVjBZVVJoZEdFaU9tNTFiR3dzSW1OdmJuUnBiblZoZEdsdmJpSTZiblZzYkN3aWRIaEpaQ0k2TkRJM01qVXdNSDAifSwiYWxnb3JpdGhtIjoiU0hBNTEydF8yNTYifQ"
 }}
```
## Chainweb P2P API

Interaction with [Chainweb P2P API][chainweb_p2p_api_doc] is done through different modules that implement functions to access the endpoints.

### Cut

A cut represents a distributed state of a chainweb. It references one block header for each chain, such that those blocks are pairwise concurrent.

Two blocks from two different chains are said to be concurrent if either one of them is an adjacent parent (is a direct dependency) of the other or if the blocks do not depend at all on each other.

#### Query the current cut from a Chainweb node

```elixir
Kadena.Chainweb.P2P.Cut.retrieve(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`

  - `query_params` (optional): Query parameters. Keyword list with:

    - `maxheight` (optional): Integer or string-encoded integer `>= 0`, represents the maximum cut height of the returned cut.

  Defaults to `[network_id: :testnet04, location: nil, query_params: []]` if not specified.

**Example**

```elixir

alias Kadena.Chainweb.P2P.Cut

Cut.retrieve(network_id: :mainnet01, location: "jp2", query_params: [maxheight: 36543])

{:ok,
 %Kadena.Chainweb.P2P.CutResponse{
   cut: %Kadena.Chainweb.Cut{
     hashes: %{
       "0": %{hash: "zkkjtWjiD68BcaISzjn5_y7-vQ3Yk2y3swhz7hm_7w8", height: 3654},
       "1": %{hash: "M-tbkEAVpS0-v5dxu-rxhRkjcVZfSE1nKEBBxNvka_g", height: 3654},
       "2": %{hash: "af5hWh0dUJoTGr5Bn8JxgDbAA97h6uqtclYi4SP95w8", height: 3654},
       "3": %{hash: "1-XVBn9NO2-g53WFzX9YpYT-t10Rr3RWJTdydMxK7Qg", height: 3654},
       "4": %{hash: "wphlMRCrkjVaIBlFNQdlTonLxGRebClL4DTHjZhgpXw", height: 3654},
       "5": %{hash: "T6iaDkYwzMBIBEyXgkFQ-T4FMhS__g6DACs4C8O27gg", height: 3654},
       "6": %{hash: "fX3NieTI5CjMs9VZEyfRqHg0B3ZKyxNkm7-p4TIfSZ4", height: 3654},
       "7": %{hash: "ddZN5o0ZNrcgmCOaEhyWb0rmpl0QcBguwfmop6uQKpI", height: 3654},
       "8": %{hash: "KEQkdXVF0nYujH43U0q-nkwDIUViZnncWol78Spoxow", height: 3654},
       "9": %{hash: "qqCoe3VfCyH6vJmn22RLIzD8DrDrKKjKlPn15UQ25TU", height: 3654}
     },
     height: 36540,
     id: "DeYKC0r8tXxZRYyx-S49sVzFCAZ8TZT3J1UlVSVmjCA",
     instance: "mainnet01",
     origin: nil,
     weight: "LKml1d8BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
   }
 }}
```
#### Publish a cut to a Chainweb node

The receiving node will first try to obtain all missing dependencies from the node that is indicated in by the origin property before searching for the dependencies in the P2P network.

```elixir
Kadena.Chainweb.P2P.Cut.publish(cut , network_opts \\ [])
```

**Parameters**

- `cut`: A Cut struct which can be created with `Kadena.Chainweb.Cut.new()`
- `network_opts`: Network options. Keyword list with:

  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`

  Defaults to `[network_id: :testnet04, location: "us1"]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb.P2P.Cut
alias Kadena.Chainweb 

origin = %{
  id: "SMS0rJlkg59bwR9Vm0HlZGsBjyt56rJtSD5DXzd_r0g",
  address: %{
    hostname: "139.144.77.27",
    port: 1788
  }
}

hashes = %{
  "0": %{hash: "N5oyYlCvq6VvyoqioTQClWXAudf_ap3gqXxSpr4V32w", height: 3_362_200},
  "1": %{hash: "CK2XPSueEx8EdkIehFMUadEBnMKZTPOfgM5-fEyoYbw", height: 3_362_200}
}

height = 67_243_992
id = "PXbSJgmFjN3A4DSz37ttYWmyrpDfzCoyivVflV3VL9A"
instance = "mainnet01"
weight = "zrmhnWgsJ-5v9gMAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

Chainweb.Cut.new()
|> Chainweb.Cut.set_hashes(hashes)
|> Chainweb.Cut.set_height(height)
|> Chainweb.Cut.set_weight(weight)
|> Chainweb.Cut.set_id(id)
|> Chainweb.Cut.set_instance(instance)
|> Chainweb.Cut.set_origin(origin)
|> Cut.publish()

{:ok,
 %Kadena.Chainweb.P2P.CutResponse{
   cut: %Kadena.Chainweb.Cut{
     hashes: %{
       "0": %{
         hash: "N5oyYlCvq6VvyoqioTQClWXAudf_ap3gqXxSpr4V32w",
         height: 3_362_200
       },
       "1": %{
         hash: "CK2XPSueEx8EdkIehFMUadEBnMKZTPOfgM5-fEyoYbw",
         height: 3_362_200
       }
     },
     height: 67_243_992,
     id: "PXbSJgmFjN3A4DSz37ttYWmyrpDfzCoyivVflV3VL9A",
     instance: "mainnet01",
     origin: %{
       address: %{hostname: "139.144.77.27", port: 1788},
       id: "SMS0rJlkg59bwR9Vm0HlZGsBjyt56rJtSD5DXzd_r0g"
     },
     weight: "zrmhnWgsJ-5v9gMAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
   }
 }}
```

### BlockHash

These endpoints return block hashes from the chain database. Generally, block hashes are returned in ascending order and include hashes from orphaned blocks.

For only querying blocks that are included in the winning `branch` of the chain the branch endpoint can be used, which returns blocks in descending order starting from the leafs of branches of the blockchain.

#### Get Block Hashes

A page of a collection of block hashes in ascending order that satisfies query parameters. Any block hash from the chain database is returned. This includes hashes of orphaned blocks.

```elixir
Kadena.Chainweb.P2P.BlockHash.retrieve(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.

  - `query_params` (optional): Query parameters. Keyword list with:

    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.
    - `minheight` (optional): Integer (`>=0`) that represents the minimum block height of the returned headers.
    - `maxheight` (optional): Integer (`>=0`) that represents the maximum block height of the returned headers. 

  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0, query_params: []]` if not specified.

**Example**

```elixir

alias Kadena.Chainweb.P2P.BlockHash

BlockHash.retrieve(location: "eu1", query_params: [limit: 5])

{:ok,
 %Kadena.Chainweb.P2P.BlockHashResponse{
   items: [
     "r21zg8E011awAbEghzNBOI4RtKUZ-wHLkUwio-5dKpE",
     "3eH11vI_wZuP3lEKcilfCx89_kZ78nFuJJbty44iNBo",
     "M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA",
     "4kaI5Wk-t3mvNZoBmVECbk_xge5SujrVh1s8S-GESKI",
     "jVP-BDWC93RfDzBVQxolPJi7RcX09ax1IMg0_I_MNIk"
   ],
   limit: 5,
   next: "inclusive:gmV-pRi50fUcy2i9v8cba_HDjw2_GP47RKgpKD-0av8"
 }}
```
#### Get Block Hash Branches

A page of block hashes from branches of the blockchain in descending order. Only blocks are returned that are ancestors of some block in the set of upper bounds and are not ancestors of any block in the set of lower bounds.

```elixir
Kadena.Chainweb.P2P.BlockHash.retrieve_branches(payload \\ [], network_opts \\ [])
```

**Parameters**
- `payload`: Keyword list with:
  - `lower` (required): Array of strings (Block Hash), no block hashes are returned that are predecessors of any block with a hash from this array.
  - `upper` (required): Array of strings (Block Hash), returned block hashes are predecessors of a block with an hash from this array. This includes blocks with hashes from this array.

  Defaults to `[lower: [], upper: []]` if not specified.

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
  - `query_params` (optional): Query parameters. Keyword list with:
  
    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.
    - `minheight` (optional): Integer (`>=0`) that represents the minimum block height of the returned headers.
    - `maxheight` (optional): Integer (`>=0`) that represents the maximum block height of the returned headers. 

  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0, query_params: []]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockHash

payload = [
  lower: ["r21zg8E011awAbEghzNBOI4RtKUZ-wHLkUwio-5dKpE"],
  upper: ["jVP-BDWC93RfDzBVQxolPJi7RcX09ax1IMg0_I_MNIk"]
]

BlockHash.retrieve_branches(payload, location: "us2", query_params: [limit: 4])

{:ok,
 %Kadena.Chainweb.P2P.BlockHashResponse{
   items: [
     "jVP-BDWC93RfDzBVQxolPJi7RcX09ax1IMg0_I_MNIk",
     "4kaI5Wk-t3mvNZoBmVECbk_xge5SujrVh1s8S-GESKI",
     "M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA",
     "3eH11vI_wZuP3lEKcilfCx89_kZ78nFuJJbty44iNBo"
   ],
   limit: 4,
   next: nil
 }}
```

### BlockHeaders

These endpoints return block headers from the chain database. Generally, block headers are returned in ascending order and include headers of orphaned blocks.

For only querying blocks that are included in the winning branch of the chain the branch endpoints can be used, which return blocks in descending order starting from the leafs of branches of the block chain.

#### Get Block Headers

A page of a collection of block headers in ascending order that satisfies query parameters. Any block header from the chain database is returned. This includes headers of orphaned blocks.

```elixir
Kadena.Chainweb.P2P.BlockHeader.retrieve(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `format` (optional): To specify the format of the returned items, the returned items could be encoded strings or decoded maps. Allowed values `:encode` and `:decode`. 
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.

  - `query_params` (optional): Query parameters. Keyword list with:

    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.
    - `minheight` (optional): Integer (`>=0`) that represents the minimum block height of the returned headers.
    - `maxheight` (optional): Integer (`>=0`) that represents the maximum block height of the returned headers. 
  

  Defaults to `[format: :encode, network_id: :testnet04, location: nil, chain_id: 0, query_params: []]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockHeader

BlockHeader.retrieve(format: :decode, query_params: [limit: 1])

{:ok,
 %Kadena.Chainweb.P2P.BlockHeaderResponse{
   items: [
     %{
       adjacents: %{
         "2": "eDSfKbJMq5CZ7F5xKrsXYvaqJTSq_A9wbc7Q2SpgCYs",
         "3": "_rvcGOcdozdWaDSgaRFc_fK1n5v41BFIHF4Ji0RCGs4",
         "5": "VWvtK_H_uRSjz3gDcSL5bnKsBRsVQHXirfofzAXWtZA"
       },
       chain_id: 0,
       chainweb_version: "testnet04",
       creation_time: 1_563_388_117_613_832,
       epoch_start: 1_563_388_117_613_832,
       feature_flags: 0,
       hash: "r21zg8E011awAbEghzNBOI4RtKUZ-wHLkUwio-5dKpE",
       height: 0,
       nonce: "0",
       parent: "A5qezNxf2ajEEloMIQeoJSFpZKqp-lsJNkt6WlJnsAk",
       payload_hash: "nfYm3e_fk2ICws0Uowos6OMuqfFg5Nrl_zqXVx9v_ZQ",
       target: "__________________________________________8",
       weight: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
     }
   ],
   limit: 1,
   next: "inclusive:3eH11vI_wZuP3lEKcilfCx89_kZ78nFuJJbty44iNBo"
 }}
```

#### Get Block Header by Hash
Query a block header by its hash.

```elixir
Kadena.Chainweb.P2P.BlockHeader.retrieve_by_hash(block_hash, network_opts \\ [])
```

**Parameters**

- `block_hash` (required): String value. Hash of a block.
- `network_opts`: Network options. Keyword list with:
  - `format` (optional): To specify the format of the returned item, the returned item could be encoded string, decoded map or a binary. Allowed values `:encode`, `:decode` and `:binary`. 
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
 
  Defaults to `[format: :encode, network_id: :testnet04, location: nil, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockHeader

hash = "M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA"

BlockHeader.retrieve_by_hash(hash, format: :decode)

{:ok,
 %Kadena.Chainweb.P2P.BlockHeaderByHashResponse{
   item: %{
     adjacents: %{
       "2": "OKrakx1LFapdQurxTNFb6qA4P-JxDu21DJuWNKzx9YQ",
       "3": "o6s-Ne3AmA1EQpNYQFGm9FnuIVGJiyyeCkMKt9Pxlwo",
       "5": "ihn-S5iteAEmY3B8xTFU6oN_yX6V5-YxrR6UMNJDbhY"
     },
     chain_id: 0,
     chainweb_version: "testnet04",
     creation_time: 1_585_882_240_125_374,
     epoch_start: 1_563_388_117_613_832,
     feature_flags: 0,
     hash: "M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA",
     height: 2,
     nonce: "0",
     parent: "3eH11vI_wZuP3lEKcilfCx89_kZ78nFuJJbty44iNBo",
     payload_hash: "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
     target: "__________________________________________8",
     weight: "AgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
   }
 }}
```

#### Get Block Header Branches

A page of block headers from branches of the blockchain in descending order. Only blocks are returned that are ancestors of some block in the set of upper bounds and are not ancestors of any block in the set of lower bounds.

```elixir
Kadena.Chainweb.P2P.BlockHeader.retrieve_branches(payload \\ [], network_opts \\ [])
```

**Parameters**
- `payload`: Keyword list with:
  - `lower` (required): Array of strings (Block Hash), no block are returned that are predecessors of any block with a hash from this array.
  - `upper` (required): Array of strings (Block Hash), returned block headers are predecessors of a block with an hash from this array. This includes blocks with hashes from this array.

  Defaults to `[lower: [], upper: []]` if not specified.

- `network_opts`: Network options. Keyword list with:
  - `format` (optional): To specify the format of the returned items, the returned items could be encoded strings or decoded maps. Allowed values `:encode` and `:decode`. 
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
  - `query_params` (optional): Query parameters. Keyword list with:

    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.
    - `minheight` (optional): Integer (`>=0`) that represents the minimum block height of the returned headers.
    - `maxheight` (optional): Integer (`>=0`) that represents the maximum block height of the returned headers. 

  Defaults to `[format: :encode, network_id: :testnet04, location: nil, chain_id: 0, query_params: []]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockHeader

payload = [
  lower: ["r21zg8E011awAbEghzNBOI4RtKUZ-wHLkUwio-5dKpE"],
  upper: ["jVP-BDWC93RfDzBVQxolPJi7RcX09ax1IMg0_I_MNIk"]
]

BlockHeader.retrieve_branches(payload, location: "us2", format: :decode, query_params: [limit: 2])

{:ok,
 %Kadena.Chainweb.P2P.BlockHeaderResponse{
   items: [
     %{
       adjacents: %{
         "2": "nONRGODRjMHiUwuWflk0wF4lKtdenX4DjWQ1JRFbv_w",
         "3": "J4rqjk-KRUnm_CpH0YdYgU-s2mVyk5158yYrlO1z_ps",
         "5": "5_yH2fMvi5YvgfWiy-CKWAX3_fb5PoRLxT-p8dR7GEQ"
       },
       chain_id: 0,
       chainweb_version: "testnet04",
       creation_time: 1585882245512236,
       epoch_start: 1563388117613832,
       feature_flags: 0,
       hash: "jVP-BDWC93RfDzBVQxolPJi7RcX09ax1IMg0_I_MNIk",
       height: 4,
       nonce: "0",
       parent: "4kaI5Wk-t3mvNZoBmVECbk_xge5SujrVh1s8S-GESKI",
       payload_hash: "EZtAeZN3UdsNsHP2v8hQ3s5uPl0u_G0juWrVIu1XqQ4",
       target: "__________________________________________8",
       weight: "BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
     },
     %{
       adjacents: %{
         "2": "23466XpUOpH-JZHOVrRNp9ZEqreMZzHNEIf-UzQ-UsU",
         "3": "x-CiDTYa1ZKYVSoAPpkKfMw_kTQykpQBXa6eWl7ZABI",
         "5": "d3rPJIeypRDoJFTYB2BmKACVaFVfyd2AWTI7fCzUzFw"
       },
       chain_id: 0,
       chainweb_version: "testnet04",
       creation_time: 1585882245418157,
       epoch_start: 1563388117613832,
       feature_flags: 0,
       hash: "4kaI5Wk-t3mvNZoBmVECbk_xge5SujrVh1s8S-GESKI",
       height: 3,
       nonce: "0",
       parent: "M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA",
       payload_hash: "tD9gYGoTZX1TktM_V61deSQ7pi5N8DP-bPgeyOkf4cg",
       target: "__________________________________________8",
       weight: "AwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
     }
   ],
   limit: 2,
   next: "inclusive:M4doD-jMHyxi4TvfBDUy3x9VMkcLxgnpjtvbbd0yUQA"
 }}
```

### BlockPayload 

Raw literal Block Payloads in the form in which they are stored on the chain. By default only the payload data is returned which is sufficient for validating the blockchain Merkle Tree. It is also sufficient as input to Pact for executing the Pact transactions of the block and recomputing the outputs.

It is also possible to query the transaction outputs along with the payload data.

#### Get Block Payload
Query a block by its payload hash.

```elixir
Kadena.Chainweb.P2P.BlockPayload.retrieve(payload_hash, network_opts \\ [])
```

**Parameters**

- `payload_hash` (required): String value. Payload hash of a block.
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
 
  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockPayload

payload_hash = "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0"

BlockPayload.retrieve(payload_hash)

{:ok,
 %Kadena.Chainweb.P2P.BlockPayloadResponse{
   miner_data:
     "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
   outputs_hash: "Ph2jHKpKxXh5UFOfU7L8_Zb-8I91WlQtCzfn6UTC5cU",
   payload_hash: "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
   transactions: [],
   transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
 }}
```
#### Get Batch of Block Payload

Query a batch for its payload hashes.

```elixir
Kadena.Chainweb.P2P.BlockPayload.retrieve_batch(payload_hashes \\ [], network_opts \\ [])
```

**Parameters**

- `payload_hashes` (required): Array of Strings (block payload hashes).
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
 
  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockPayload

payload_hashes = [
  "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
  "EZtAeZN3UdsNsHP2v8hQ3s5uPl0u_G0juWrVIu1XqQ4"
]

BlockPayload.retrieve_batch(payload_hashes)

{:ok,
 %Kadena.Chainweb.P2P.BlockPayloadBatchResponse{
   batch: [
     %{
       miner_data:
         "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
       outputs_hash: "Ph2jHKpKxXh5UFOfU7L8_Zb-8I91WlQtCzfn6UTC5cU",
       payload_hash: "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
       transactions: [],
       transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
     },
     %{
       miner_data:
         "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
       outputs_hash: "KG91xchUDjg0z9HPbe8u1_8q-aotv1e2Q1QtMIqII2c",
       payload_hash: "EZtAeZN3UdsNsHP2v8hQ3s5uPl0u_G0juWrVIu1XqQ4",
       transactions: [],
       transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
     }
   ]
 }}

```

#### Get Block Payload With Outputs

Query a block with outputs by its payload hash.

```elixir
Kadena.Chainweb.P2P.BlockPayload.retrieve(payload_hash, network_opts \\ [])
```

**Parameters**

- `payload_hash` (required): String value. Payload hash of a block.
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
 
  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockPayload

payload_hash = "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0"

BlockPayload.with_outputs(payload_hash)

{:ok,
 %Kadena.Chainweb.P2P.BlockPayloadWithOutputsResponse{
   coinbase:
     "eyJnYXMiOjAsInJlc3VsdCI6eyJzdGF0dXMiOiJzdWNjZXNzIiwiZGF0YSI6IldyaXRlIHN1Y2NlZWRlZCJ9LCJyZXFLZXkiOiJJak5sU0RFeGRrbGZkMXAxVUROc1JVdGphV3htUTNnNE9WOXJXamM0YmtaMVNrcGlkSGswTkdsT1FtOGkiLCJsb2dzIjoiUkFuWnh1S2NfaFNrZU5OVHBZQUZFVDZTS1BDWVVhczRvOUlEVl92MlNPayIsIm1ldGFEYXRhIjpudWxsLCJjb250aW51YXRpb24iOm51bGwsInR4SWQiOjEwfQ",
   miner_data:
     "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
   outputs_hash: "Ph2jHKpKxXh5UFOfU7L8_Zb-8I91WlQtCzfn6UTC5cU",
   payload_hash: "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
   transactions: [],
   transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
 }}
```
#### Get Batch of Block Payload With Outputs

Query a batch with outputs for its payload hashes.

```elixir
Kadena.Chainweb.P2P.BlockPayload.retrieve_batch(payload_hashes \\ [], network_opts \\ [])
```

**Parameters**

- `payload_hashes` (required): Array of Strings (block payload hashes).
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
 
  Defaults to `[network_id: :testnet04, location: nil, chain_id: 0]` if not specified.

**Example**

```elixir
alias Kadena.Chainweb.P2P.BlockPayload

payload_hashes = [
  "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
  "EZtAeZN3UdsNsHP2v8hQ3s5uPl0u_G0juWrVIu1XqQ4"
]

BlockPayload.batch_with_outputs(payload_hashes)

{:ok,
 %Kadena.Chainweb.P2P.BlockPayloadBatchWithOutputsResponse{
   batch: [
     %{
       coinbase:
         "eyJnYXMiOjAsInJlc3VsdCI6eyJzdGF0dXMiOiJzdWNjZXNzIiwiZGF0YSI6IldyaXRlIHN1Y2NlZWRlZCJ9LCJyZXFLZXkiOiJJak5sU0RFeGRrbGZkMXAxVUROc1JVdGphV3htUTNnNE9WOXJXamM0YmtaMVNrcGlkSGswTkdsT1FtOGkiLCJsb2dzIjoiUkFuWnh1S2NfaFNrZU5OVHBZQUZFVDZTS1BDWVVhczRvOUlEVl92MlNPayIsIm1ldGFEYXRhIjpudWxsLCJjb250aW51YXRpb24iOm51bGwsInR4SWQiOjEwfQ",
       miner_data:
         "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
       outputs_hash: "Ph2jHKpKxXh5UFOfU7L8_Zb-8I91WlQtCzfn6UTC5cU",
       payload_hash: "R_CYH-5qSKnB9eLlXply7DRFdPUoAF02VNKU2uXR8_0",
       transactions: [],
       transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
     },
     %{
       coinbase:
         "eyJnYXMiOjAsInJlc3VsdCI6eyJzdGF0dXMiOiJzdWNjZXNzIiwiZGF0YSI6IldyaXRlIHN1Y2NlZWRlZCJ9LCJyZXFLZXkiOiJJalJyWVVrMVYyc3RkRE50ZGs1YWIwSnRWa1ZEWW10ZmVHZGxOVk4xYW5KV2FERnpPRk10UjBWVFMwa2kiLCJsb2dzIjoidHBJUG8zR3g0QXV6QjFZRk9jWEhyTVU3R1lmaW9BcEp6YWNVSjVqc0RvWSIsIm1ldGFEYXRhIjpudWxsLCJjb250aW51YXRpb24iOm51bGwsInR4SWQiOjEyfQ",
       miner_data:
         "eyJhY2NvdW50IjoidXMxIiwicHJlZGljYXRlIjoia2V5cy1hbGwiLCJwdWJsaWMta2V5cyI6WyJkYjc3Njc5M2JlMGZjZjhlNzZjNzViZGIzNWEzNmU2N2YyOTgxMTFkYzYxNDVjNjY2OTNiMDEzMzE5MmUyNjE2Il19",
       outputs_hash: "KG91xchUDjg0z9HPbe8u1_8q-aotv1e2Q1QtMIqII2c",
       payload_hash: "EZtAeZN3UdsNsHP2v8hQ3s5uPl0u_G0juWrVIu1XqQ4",
       transactions: [],
       transactions_hash: "AvpbbrgkfNtMI6Hq0hJWZatbwggEKppNYL5rAXJakrw"
     }
   ]
 }}
```

### Mempool P2P Endpoints
Mempool P2P endpoints for communication between mempools. Endusers are not supposed to use these endpoints directly. Instead, the respective Pact endpoints should be used for submitting transactions into the network.

#### Get Pending Transactions from the Mempool

```elixir
Kadena.Chainweb.P2P.Mempool.retrieve_pending_txs(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
  - `query_params` (optional): Query parameters. Keyword list with:
    - `nonce`: Integer value. Server nonce value.
    - `since`: Integer value. Mempool tx id value.

  Defaults to `[network_id: :testnet04, location: "us1", chaind_id: 0]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb.P2P.Mempool

Mempool.retrieve_pending_txs(
  network_id: :mainnet01,
  query_params: [nonce: 1_585_882_245_418_157, since: 20_160_180]
)

{:ok,
 %Kadena.Chainweb.P2P.MempoolRetrieveResponse{
   hashes: [
     "XXmh7EV8fZpb0facydq2bWOKMDrFC9wZTbbolYaFsgQ",
     "cTAhpGkkBnXkPJPlawx1iPo2V-N54f83cpSQfXN-nNI"
   ],
   highwater_mark: [-2_247_324_167_920_489_014, 103_370]
 }}

```

#### Check for Pending Transactions in the Mempool

```elixir
Kadena.Chainweb.P2P.Mempool.check_pending_txs(request_keys \\ [], network_opts \\ [])
```

**Parameters**

- `request_keys` (required): Array of Strings. Request key of a Pact transaction.
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, location: "us1", chaind_id: 0]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`
  
**Example**

```elixir
alias Kadena.Chainweb.P2P.Mempool

request_keys = [
  "C385m6e9S7WzelUFCyW-JoZFJGQNlcI0jqCO8YrPMVo",
  "hK1dutkawvL5Pt79rMzA8JnQZyUesAY0ce8XL0sHIqc"
]

Mempool.check_pending_txs(request_keys, network_id: :mainnet01)

{:ok, %Kadena.Chainweb.P2P.MempoolCheckResponse{results: [true, false]}}

```
#### Lookup Pending Transactions in the Mempool

```elixir
Kadena.Chainweb.P2P.Mempool.lookup_pending_tx(request_keys \\ [], network_opts \\ [])
```

**Parameters**

- `request_keys` (required): Array of Strings. Request key of a Pact transaction.
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.

  Defaults to `[network_id: :testnet04, location: "us1", chaind_id: 0]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`
  
**Example**

```elixir
alias Kadena.Chainweb.P2P.Mempool

request_keys = [
  "C385m6e9S7WzelUFCyW-JoZFJGQNlcI0jqCO8YrPMVo",
  "hK1dutkawvL5Pt79rMzA8JnQZyUesAY0ce8XL0sHIqc"
]

Mempool.lookup_pending_txs(request_keys, network_id: :mainnet01)

{:ok,
 %Kadena.Chainweb.P2P.MempoolLookupResponse{
   results: [
     %{
       contents:
         "{\"hash\":\"C385m6e9S7WzelUFCyW-JoZFJGQNlcI0jqCO8YrPMVo\",\"sigs\":[],\"cmd\":\"{\\\"networkId\\\":\\\"mainnet01\\\",\\\"payload\\\":{\\\"cont\\\":{\\\"proof\\\":\\\"eyJjaGFpbiI6MCwib2JqZWN0IjoiQUFBQUVRQUFBQUFBQUFBQ0FNQldwNWtIdGs2bnpxVXVJMzhIdlZ5bUNaS21BUU9DMlp1RHFqWEx1Z3VjQUxvcTk2R0lsZGlaSnNNYnI5Y0VTYl9Gam9TVlI0QTRBMThQNS0zVnl2OFRBVjhtRkcyc1RyVVN5bGVzVmlqWUxVVmFWSE1wbE1zRlhPRHRyTGNYOVdxbkFhOVk3eFVXSUN2cmVMSmctZVpGQWQ0aDAtbFlUVVFydkZiQl9tZnNMaWRQQUUzWXh0WHJJcl9qenpUbkhuOWdCd0Vrc19EUzZtUXBmblZ0dEIySVFCRUVBYUtsZ05mdFd6VGpib2xWS0tBNDBIWDltTUxkZU44TzJnSm5HZm9jMlpsT0FJUlZWcU9ULXlDSjFaSC1qWGJMVzB6X21MUlB2QVZtblJCS3NiZnF1VlZ3QUtzN0lCTFN4M2VtOFdFSS1RV3k1UEI3bDY3QUpzZ2NoemxzV21FUjBiUVhBZWpZUEFmUm5ONDByUExfZ1QtUHpnZVZzU1A0VEtqcXVlaVdTQjZUc3M0bEFMaG04bFFSdFFKSkV4bVJtRTZZU0lFeE1VM2w5UkVQT0ZFN3lDcHc4MTE2QWVYWHhGcFJMUlh4ZWlranR3QnpteS1HZ1FMVnUwQVpSbnpJa1hUcS02bnRBQUpvSVl4Rjloeld5Zjc1VVJlUFJ2enV1eW1ZUjRDdkI2OW1laHR5UnBLUUFGRUZDMVdMY2Z4bWNCe" <>
           ...,
       tag: "Pending"
     },
     %{tag: "Missing"}
   ]
 }}

```

### Peer Endpoints

The P2P communication between chainweb-nodes is sharded into several independent P2P network. The `cut` network is exchanging consensus state. There is also one mempool P2P network for each chain.

#### Get Cut-Network Peer Info

```elixir
Kadena.Chainweb.P2P.Peer.retrieve_cut_info(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `query_params` (optional): Query parameters. Keyword list with:
    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.

  Defaults to `[network_id: :testnet04, location: "us1", query_params: []]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb.P2P.Peer

Peer.retrieve_cut_info(network_id: :mainnet01, query_params: [next: "inclusive:5", limit: 5])

{:ok,
 %Kadena.Chainweb.P2P.PeerResponse{
   items: [
     %{
       address: %{hostname: "202.61.244.124", port: 31_350},
       id: "NGWAyrXN7KTJ0pGCrSjepT2JIkmQoR3F6uShBakwogU"
     },
     %{
       address: %{hostname: "202.61.244.182", port: 31_350},
       id: "jzeetZdYpIVVMakXF3gPZewFvA2y7ITl-s9n88onPrk"
     },
     %{
       address: %{hostname: "34.68.148.186", port: 1789},
       id: "LeRJC7adbr2Mtbpo1jGJYST0X1_QKNBmXGVNApX-Edo"
     },
     %{
       address: %{hostname: "77.197.133.174", port: 31_350},
       id: "H807vFwc8mADojurOO93gT-KRTbEhClpmn6iu5t_cCA"
     },
     %{
       address: %{hostname: "35.76.76.135", port: 1789},
       id: "flE2czzEK67A22L7iz2qrWoYXkjqG0E9e1TNii-bXpE"
     }
   ],
   limit: 5,
   next: "inclusive:10"
 }}

```

#### Put Cut-Network Peer Info
Allows to add a peer to the peer database of the cut P2P network of the remote host.

```elixir
Kadena.Chainweb.P2P.Peer.put_cut_info(peer, network_opts \\ [])
```

**Parameters**

- `peer`: A Peer struct which can be created with `Kadena.Chainweb.Peer.new()`
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`

  Defaults to `[network_id: :testnet04, location: "us1", query_params: []]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb
alias Kadena.Chainweb.P2P.Peer

address = %{
  hostname: "77.197.133.174",
  port: 31_350
}

id = "PRLmVUcc9AH3fyfMYiWeC4nV2i1iHwc0-aM7iAO8h18"

Chainweb.Peer.new()
|> Chainweb.Peer.set_id(id)
|> Chainweb.Peer.set_address(address)
|> Peer.put_cut_info(network_id: :mainnet01)

{:ok,
 %Kadena.Chainweb.P2P.PeerPutResponse{
   peer: %Kadena.Chainweb.Peer{
     address: %{hostname: "77.197.133.174", port: 31_350},
     id: "PRLmVUcc9AH3fyfMYiWeC4nV2i1iHwc0-aM7iAO8h18"
   }
 }}

```

#### Get Chain Mempool-Network Peer Info

```elixir
Kadena.Chainweb.P2P.Peer.retrieve_mempool_info(network_opts \\ [])
```

**Parameters**

- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`
  - `query_params` (optional): Query parameters. Keyword list with:
    - `limit` (optional): Integer (`>=0`) that represents the maximum number of records that may be returned.
    - `next` (optional): String of the cursor for the next page. This value can be found as value of the next property of the previous page.

  Defaults to `[network_id: :testnet04, chain_id: 0, location: "us1", query_params: []]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb.P2P.Peer

Peer.retrieve_mempool_info(network_id: :mainnet01, query_params: [next: "inclusive:2", limit: 5])

{:ok,
 %Kadena.Chainweb.P2P.PeerResponse{
   items: [
     %{
       address: %{hostname: "65.108.9.161", port: 31_350},
       id: "_VA2_QqnUHXxekBiJT4ypxAi7znsR7oEsVRS_wk46nk"
     },
     %{
       address: %{hostname: "65.108.9.188", port: 31_350},
       id: "VQmD_ESHjDc_PBq15BShzJJZ74btZ_pIsK3jQSnXOkc"
     },
     %{
       address: %{hostname: "202.61.244.124", port: 31_350},
       id: "NGWAyrXN7KTJ0pGCrSjepT2JIkmQoR3F6uShBakwogU"
     },
     %{
       address: %{hostname: "202.61.244.182", port: 31_350},
       id: "jzeetZdYpIVVMakXF3gPZewFvA2y7ITl-s9n88onPrk"
     },
     %{
       address: %{hostname: "34.68.148.186", port: 1789},
       id: "LeRJC7adbr2Mtbpo1jGJYST0X1_QKNBmXGVNApX-Edo"
     }
   ],
   limit: 5,
   next: "inclusive:7"
 }}

```

#### Put Chain Mempool-Network Peer Info
Allows to add a peer to the peer database of the mempool P2P network of the chain `chain_id` of remote host.

```elixir
Kadena.Chainweb.P2P.Peer.put_mempool_info(peer, network_opts \\ [])
```

**Parameters**

- `peer`: A Peer struct which can be created with `Kadena.Chainweb.Peer.new()`
- `network_opts`: Network options. Keyword list with:
  - `network_id` (required): Allowed values: `:testnet04` `:mainnet01`.
  - `chain_id` (required): Id of the chain to which the request is sent. Allowed values: integer or string-encoded integer from 0 to 19.
  - `location` (optional): Location to access a Chainweb P2P bootstrap node. Allowed values:
    - testnet: `"us1"`, `"us2"`, `"eu1"`, `"eu2"`, `"ap1"`, `"ap2"`
    - mainnet: `"us-e1"`, `"us-e2"`, `"us-e3"`, `"us-w1"`, `"us-w2"`, `"us-w3"`, `"fr1"`, `"fr2"`, `"fr3"`, `"jp1"`, `"jp2"`, `"jp3"`

  Defaults to `[network_id: :testnet04, chain_id: 0, location: "us1", query_params: []]` if not specified. If `network_id` is set as `:mainnet01` the default `location` is `"us-e1"`

**Example**

```elixir
alias Kadena.Chainweb
alias Kadena.Chainweb.P2P.Peer

address = %{
  hostname: "77.197.133.174",
  port: 31_350
}

id = "PRLmVUcc9AH3fyfMYiWeC4nV2i1iHwc0-aM7iAO8h18"

Chainweb.Peer.new()
|> Chainweb.Peer.set_id(id)
|> Chainweb.Peer.set_address(address)
|> Peer.put_mempool_info(network_id: :mainnet01)

{:ok,
 %Kadena.Chainweb.P2P.PeerPutResponse{
   peer: %Kadena.Chainweb.Peer{
     address: %{hostname: "77.197.133.174", port: 31_350},
     id: "PRLmVUcc9AH3fyfMYiWeC4nV2i1iHwc0-aM7iAO8h18"
   }
 }}

```
---

## Roadmap

You can see a big picture of the roadmap here: [**ROADMAP**][roadmap]

### Done - What we've already developed! 🚀

<details>
<summary>Click to expand!</summary>

- [Base types](https://github.com/kommitters/kadena.ex/issues/11)
- [Keypair types](https://github.com/kommitters/kadena.ex/issues/12)
- [PactValue types](https://github.com/kommitters/kadena.ex/issues/15)
- [SignCommand types](https://github.com/kommitters/kadena.ex/issues/16)
- [ContPayload types](https://github.com/kommitters/kadena.ex/issues/28)
- [Cap types](https://github.com/kommitters/kadena.ex/issues/30)
- [ExecPayload types](https://github.com/kommitters/kadena.ex/issues/32)
- [PactPayload types](https://github.com/kommitters/kadena.ex/issues/34)
- [MetaData and Signer types](https://github.com/kommitters/kadena.ex/issues/35)
- [CommandPayload types](https://github.com/kommitters/kadena.ex/issues/36)
- [PactExec types](https://github.com/kommitters/kadena.ex/issues/40)
- [PactEvents types](https://github.com/kommitters/kadena.ex/issues/41)
- [CommandResult types](https://github.com/kommitters/kadena.ex/issues/43)
- [PactCommand types](https://github.com/kommitters/kadena.ex/issues/13)
- [PactAPI types](https://github.com/kommitters/kadena.ex/issues/17)
- [Wallet types](https://github.com/kommitters/kadena.ex/issues/18)
- [Kadena Crypto](https://github.com/kommitters/kadena.ex/issues/51)
- [Kadena Pact](https://github.com/kommitters/kadena.ex/issues/55)
- [Pact Commands Builder](https://github.com/kommitters/kadena.ex/issues/131)
- [Chainweb](https://github.com/kommitters/kadena.ex/issues/57)
- [Chainweb P2P API](https://github.com/kommitters/kadena.ex/milestone/1)
- [Accept request commands as YAML files](https://github.com/kommitters/kadena.ex/milestone/2)

</details>

---

## Development

- Install any Elixir version above 1.13.
- Compile dependencies: `mix deps.get`
- Run tests: `mix test`.

## Want to jump in?

Check out our [Good first issues][good-first-issues], this is a great place to start contributing if you're new to the project!

We welcome contributions from anyone! Check out our [contributing guide][contributing] for more information.

## Changelog

Features and bug fixes are listed in the [CHANGELOG][changelog] file.

## Code of conduct

We welcome everyone to contribute. Make sure you have read the [CODE_OF_CONDUCT][coc] before.

## Contributing

For information on how to contribute, please refer to our [CONTRIBUTING][contributing] guide.

## License

This library is licensed under an MIT license. See [LICENSE][license] for details.

## Acknowledgements

Made with 💙 by [kommitters Open Source](https://kommit.co)

[license]: https://github.com/kommitters/kadena.ex/blob/main/LICENSE
[coc]: https://github.com/kommitters/kadena.ex/blob/main/CODE_OF_CONDUCT.md
[changelog]: https://github.com/kommitters/kadena.ex/blob/main/CHANGELOG.md
[contributing]: https://github.com/kommitters/kadena.ex/blob/main/CONTRIBUTING.md
[roadmap]: https://github.com/orgs/kommitters/projects/5/views/3
[good-first-issues]: https://github.com/kommitters/kadena.ex/labels/%F0%9F%91%8B%20Good%20first%20issue
[http_client_spec]: https://github.com/kommitters/kadena.ex/blob/main/lib/chainweb/client/spec.ex
[jason_url]: https://github.com/michalmuskala/jason
[chainweb_pact_api_doc]: https://api.chainweb.com/openapi/pact.html
[chainweb_pact_api]: https://github.com/kommitters/kadena.ex/blob/main/lib/chainweb/pact.ex
[chainweb_p2p_api_doc]: https://api.chainweb.com/openapi/#tag/p2p_api
