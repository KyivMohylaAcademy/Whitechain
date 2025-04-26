# Web3 Login Implementation Documentation 

## Objective 
The goal was the implementation of basic user authorisation through a Web3 wallet (MetaMask). This should be an alternative to traditional authorisation (login + password).

### System Component Requirements (Frontend):

- A simple page with a button "Login via Web3".
- When you click on the button:
    - Check if a Web3 wallet in the browser (MetaMask) is launched.
    - The user connects the wallet.

## Project Structure 
```
/web3-login
  ├── index.html 
  ├── main.js      
  ├── package-lock.json
  ├── package.json        
  └── README.md
  ```

## Deployment ##
1. Clone the repository:
   ```
   git clone https://github.com/Lifencev/web3-login.git
   ```
2. Navigate to the project directory:
   ```
   cd web3-login
   ```
3. Install Dependencies:
    ```
    npm install
    ```
4. To test the app locally:
    ```
    npx live-server
    ```

Make sure MetaMask is installed and unlocked before testing.
