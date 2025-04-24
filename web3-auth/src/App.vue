<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { getConnectors, type Connector, connect, getAccount, type GetAccountReturnType, reconnect, disconnect } from '@wagmi/core'
import { wagmiConfig } from './config/wagmi';

const availableWeb3Connectors = ref<readonly Connector[]>()

const connectedAccount = ref<GetAccountReturnType<typeof wagmiConfig>>()
const isConnecting = ref(false)

const onWeb3LoginButtonClick = () => {
  isConnecting.value = true
}

const onConnectorButtonClick = async (connector: Connector) => {
  const result = await connect(wagmiConfig, {
    connector
  })

  if(result.accounts.length > 0) {
    connectedAccount.value = getAccount(wagmiConfig)
  }
}

const onDisconnectButtonClick = async () => {
  await disconnect(wagmiConfig)
  connectedAccount.value = getAccount(wagmiConfig)
}

onMounted(async () => {
  await reconnect(wagmiConfig)
  connectedAccount.value = getAccount(wagmiConfig)
  availableWeb3Connectors.value = getConnectors(wagmiConfig)
})
</script>

<template>
  <main class="min-h-screen grid place-items-center">
    <div class="flex flex-col items-center gap-4" v-if="connectedAccount?.isConnected">
      <span>
        Your account: {{ connectedAccount.address }}
      </span>
      <button 
        class="bg-red-400 rounded-lg p-4 text-white hover:bg-red-600 hover:cursor-pointer" 
        @click="onDisconnectButtonClick"
      >
        Disconnect
      </button>
    </div>
    <div v-else>
      <button 
        v-if="!isConnecting"
        class="bg-blue-400 rounded-lg p-4 text-white hover:bg-blue-600 hover:cursor-pointer" 
        @click="onWeb3LoginButtonClick"
      >
        Увійти через Web3
      </button>
      <div v-else>
        <div class="mb-4">Available connectors:</div>
        <button @click="onConnectorButtonClick(connector)" class="flex flex-row items-center gap-3 bg-blue-400 hover:bg-blue-600 p-4 hover:cursor-pointer rounded-lg text-white" v-for="connector in availableWeb3Connectors">
          <img v-if="connector.icon" :src="connector.icon" :alt="connector.name">
          <span>
            {{ connector.name }}
          </span>
        </button >
      </div>
    </div>
  </main>
</template>