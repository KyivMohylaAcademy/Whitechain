// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VotingRegistryModule = buildModule("VotingRegistryModule", (m) => {
  const votingRegistry = m.contract("VotingRegistry");

  return {
    votingRegistry
  }
});

export default VotingRegistryModule;
