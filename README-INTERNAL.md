# Setup

```
npm install

# Compile contracts
npm run compile
```

# Deploy

```
# Setup network env
# `truffle` - internal truffle network
# `ganache_cli` - in conjunction with `npm run ganache-cli`
# `other` - with `other` RPC (fork, ropsten, mainnet, ...)
export NODE_ENV=network

# Edit appropriate `.env.network.local`. See `.env.defaults` for comments.

# Run deployment
./deploy.sh
```

# Test

```
npm run test
```

# Dapp integration

```
# Copy artifacts to dapp
./artifacts2dapp.sh
```

# External calls

```
# In case of 'notifyRewardAmount'
./edda-notify-reward-amount.sh
# or
./uni-edda-notify-reward-amount.sh
```

# Prepare contracts for audit

```
$ npm run merge-contracts
```

# Copy to GitHUB

```
$ ./copy2github.sh  existing_target_path
```
