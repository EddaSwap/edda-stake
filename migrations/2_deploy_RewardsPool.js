const { BN, time } = require('@openzeppelin/test-helpers')

const ENV = require('../config/env.js')

const EDDARewardsPoolArtifact = artifacts.require('EDDARewardsPool')
const UniEDDARewardsPoolArtifact = artifacts.require('UniEDDARewardsPool')

let UniWethEddaArtifact
let EDDAArtifact
if (ENV.DEPLOY_FAKE_CONTRACTS) {
  UniWethEddaArtifact = artifacts.require('UniWethEdda')
  EDDAArtifact = artifacts.require('EDDA')
}

module.exports = async function (deployer, network, accounts) {
  let eddaAddress = ENV.EDDA_TOKEN_ADDRESS
  console.log(`eddaAddress from ENV ${eddaAddress}`)
  if (ENV.DEPLOY_FAKE_CONTRACTS) {
    console.log(`ENV.DEPLOY_FAKE_CONTRACTS ${ENV.DEPLOY_FAKE_CONTRACTS}`)
    await deployer.deploy(EDDAArtifact)
    const edda = await EDDAArtifact.deployed()
    eddaAddress = await edda.address
  }
  console.log(`eddaAddress          ${eddaAddress}`)

  await deployer.deploy(
    EDDARewardsPoolArtifact,
    eddaAddress,
    eddaAddress,
    accounts[0],
    eval(ENV.UNI_EDDA_STAKE_DURATION_SECONDS)
  )

  let uniWethEddaAddress = ENV.UNI_WETH_EDDA_ADDRESS
  console.log(`uniWethEddaAddress from ENV ${uniWethEddaAddress}`)
  if (ENV.DEPLOY_FAKE_CONTRACTS) {
    console.log(`ENV.DEPLOY_FAKE_CONTRACTS ${ENV.DEPLOY_FAKE_CONTRACTS}`)
    await deployer.deploy(UniWethEddaArtifact)
    const uniWethEdda = await UniWethEddaArtifact.deployed()
    uniWethEddaAddress = await uniWethEdda.address
  }
  console.log(`uniWethEddaAddress          ${uniWethEddaAddress}`)

  await deployer.deploy(
    UniEDDARewardsPoolArtifact,
    uniWethEddaAddress,
    eddaAddress,
    accounts[0],
    eval(ENV.UNI_EDDA_STAKE_DURATION_SECONDS)
  )
}
