<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { connect, disconnect, getAccount, getConnectors, reconnect } from '@wagmi/core'
import { wagmiConfig } from './web3'

const connectors = ref(getConnectors(wagmiConfig))  // доступні конектори
const user = ref(getAccount(wagmiConfig))           // поточний акаунт
const selectingConnector = ref(false)               // чи показувати вибір конектора

// Обробка підключення конектора
const handleConnection = async (walletConnector) => {
  const result = await connect(wagmiConfig, { connector: walletConnector })

  if (result.accounts.length) {
    user.value = getAccount(wagmiConfig)
    selectingConnector.value = false
  }
}

// Автоматичне підключення при завантаженні сторінки
onMounted(async () => {
  await reconnect(wagmiConfig)
  user.value = getAccount(wagmiConfig)
})

// Обробка відключення
const logout = async () => {
  await disconnect(wagmiConfig)
  user.value = getAccount(wagmiConfig)
}
</script>

<template>
  <div class="flex flex-wrap gap-10 justify-center items-center w-full h-[100vh] bg-[#E8E8E8]">
    <div class="rounded-2xl bg-[#FFFFFF] flex justify-center items-center w-1/6 h-1/2">
      <div class="flex flex-col gap-5 justify-center items-center">
          <div v-if="user?.isConnected">
            <p class="connected-text">Connected: </p>
            <div class="connected-address">{{ user.address }}</div>
            <button
                @click="logout"
                class="logout-button"
            >
              Logout
            </button>
          </div>


          <div v-else>
                <button
                    v-if="!selectingConnector"
                    @click="selectingConnector = true"
                    class="login-button"
                >
                  Login
                </button>

                <div v-else class="connector-wrapper">
                  <span class="choose-wallet-text">Login with wallet:</span>
                  <button
                      v-for="wallet in connectors"
                      :key="wallet.id"
                      @click="handleConnection(wallet)"
                      class="wallet-button"
                  >
                    <img v-if="wallet.icon" :src="wallet.icon" :alt="wallet.name" class="wallet-icon">
                    <span>{{ wallet.name }}</span>
                  </button>
                </div>

              </div>
          </div>
      </div>
  </div>
</template>

<style scoped>

.login-button {
  background-color: #1e1e3a;
  color: white;
  font-weight: 600;
  font-size: 1.125rem;
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.login-button:hover {
  background-color: #ebbe52;
}

.connector-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.choose-wallet-text {
  font-size: 1.125rem;
  font-weight: 500;
}

.wallet-button {
  background-color: #3b82f6;
  color: white;
  padding: 0.75rem 1.25rem;
  border-radius: 0.5rem;
  border: none;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.wallet-button:hover {
  background-color: #1d4ed8;
}

.wallet-icon {
  width: 24px;
  height: 24px;
}

.connected-text {
  font-size: 1.25rem;
  font-weight: bold;
}
.connected-address {
  font-size: 0.65rem;
  font-weight: bold;
}

.logout-button {
  background-color: #5D0909;
  color: white;
  padding: 0.75rem 1.25rem;
  border-radius: 0.5rem;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s;
}

.logout-button:hover {
  background-color: #ebbe52;
}


</style>