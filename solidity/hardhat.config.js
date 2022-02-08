require("@nomiclabs/hardhat-waffle");

const path = require('path')
require('dotenv').config({ path: path.resolve(__dirname, '.env') })

// Environment variable examples - https://stackoverflow.com/questions/42335016/dotenv-file-is-not-loading-environment-variables
const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.0",
  networks: {
    rinkeby: {
      url: API_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};