// Клас для Web3 авторизації
class Web3Auth {
    constructor() {
        this.isConnected = false;
        this.account = null;
        this.chainId = null;
        this.networkName = null;
        
        // Елементи DOM
        this.connectButton = document.getElementById('connectButton');
        this.statusDiv = document.getElementById('status');
        this.accountInfoDiv = document.getElementById('accountInfo');
        this.accountAddressSpan = document.getElementById('accountAddress');
        this.networkNameSpan = document.getElementById('networkName');
        
        // Перевірка наявності MetaMask
        this.checkMetaMaskPresence();
        
        // Додання обробників подій
        if (this.connectButton) {
            this.connectButton.addEventListener('click', () => this.connect());
        }
    }
    
    // Перевірка наявності MetaMask
    checkMetaMaskPresence() {
        if (typeof window.ethereum !== 'undefined') {
            this.statusDiv.textContent = 'MetaMask виявлено. Натисніть кнопку для підключення.';
            this.connectButton.disabled = false;
        } else {
            this.statusDiv.textContent = 'MetaMask не знайдено. Будь ласка, встановіть MetaMask для використання цієї функції.';
            this.connectButton.disabled = true;
        }
    }
    
    // Підключення до MetaMask
    async connect() {
        try {
            this.statusDiv.textContent = 'Підключення до MetaMask...';
            
            // Запит на підключення до гаманця
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            this.account = accounts[0];
            
            // Отримання інформації про мережу
            this.chainId = await window.ethereum.request({ method: 'eth_chainId' });
            this.networkName = this.getNetworkName(this.chainId);
            
            // Відображення інформації
            this.accountAddressSpan.textContent = this.account;
            this.networkNameSpan.textContent = this.networkName;
            this.accountInfoDiv.style.display = 'block';
            
            this.statusDiv.textContent = 'Успішно підключено!';
            this.connectButton.textContent = 'Підключено';
            this.connectButton.disabled = true;
            this.isConnected = true;
            
            // Встановлення слухачів подій
            this.setupEventListeners();
            
        } catch (error) {
            this.statusDiv.textContent = `Помилка: ${error.message}`;
            console.error('Error connecting to MetaMask:', error);
        }
    }
    
    // Встановлення слухачів подій
    setupEventListeners() {
        // Обробка зміни гаманця
        window.ethereum.on('accountsChanged', (newAccounts) => {
            if (newAccounts.length === 0) {
                // Користувач відключився
                this.resetConnection();
            } else {
                // Змінилася адреса гаманця
                this.account = newAccounts[0];
                this.accountAddressSpan.textContent = this.account;
            }
        });
        
        // Обробка зміни мережі
        window.ethereum.on('chainChanged', (newChainId) => {
            this.chainId = newChainId;
            this.networkName = this.getNetworkName(this.chainId);
            this.networkNameSpan.textContent = this.networkName;
        });
        
        // Обробка відключення
        window.ethereum.on('disconnect', () => {
            this.resetConnection();
        });
    }
    
    // Скидання підключення
    resetConnection() {
        this.isConnected = false;
        this.account = null;
        this.chainId = null;
        this.networkName = null;
        
        this.accountInfoDiv.style.display = 'none';
        this.statusDiv.textContent = 'Відключено від MetaMask. Натисніть кнопку для підключення.';
        this.connectButton.textContent = 'Увійти через Web3';
        this.connectButton.disabled = false;
    }
    
    // Отримання назви мережі за chainId
    getNetworkName(chainId) {
        const networks = {
            '0x1': 'Ethereum Mainnet',
            '0x3': 'Ropsten Testnet',
            '0x4': 'Rinkeby Testnet',
            '0x5': 'Goerli Testnet',
            '0xaa36a7': 'Sepolia Testnet',
            '0x38': 'Binance Smart Chain',
            '0x89': 'Polygon (Matic)',
            '0xa86a': 'Avalanche'
        };
        
        return networks[chainId] || `Невідома мережа (Chain ID: ${chainId})`;
    }
}

// Ініціалізація після завантаження сторінки
document.addEventListener('DOMContentLoaded', () => {
    const web3Auth = new Web3Auth();
});