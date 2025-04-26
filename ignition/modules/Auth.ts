import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const AuthModule = buildModule("AuthModule", (m) => {
  const auth = m.contract("Auth", []);

  return { auth };
});

export default AuthModule;
