import { createConfig, http } from "@wagmi/core";
import { mainnet } from '@wagmi/chains'

export const wagmiConfig = createConfig({
  chains: [mainnet],
  transports: {
    [mainnet.id]: http()
  }
})