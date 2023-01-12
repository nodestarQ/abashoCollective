const {TwitterApi} = require("twitter-api-v2");

require('dotenv').config();

const client = new TwitterApi({
  appKey:         process.env.APP_KEY,
  appSecret:      process.env.APP_SECRET,
  accessToken:    process.env.ACCESS_TOKEN,
  accessSecret:   process.env.ACCESS_SECRET,
})

const rwClient = client.readWrite

const aClient = new TwitterApi(process.env.BEARER_TOKEN);
const appClient = aClient.readWrite;

module.exports = {rwClient, appClient}