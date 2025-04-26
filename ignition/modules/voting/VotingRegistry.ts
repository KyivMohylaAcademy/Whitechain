import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VotingRegistryModule = buildModule("VotingRegistryModule", (m) => {
  const votingRegistry = m.contract("VotingRegistry", []);

  return { votingRegistry };
});

export default VotingRegistryModule;
