const { ETwitterStreamEvent} = require('twitter-api-v2');
const clients = require("./twitterClient.js");
console.log("HUGBASHO HAS BEEN STARTED");

//stream on and look for mentions
lookForHugs();

async function lookForHugs() {

    const hugbashoId = "1612581220503769088"; //this is our twitter user ID
    
    //Create Rules
    const rules = await clients.appClient.v2.streamRules();
    if (rules.data?.length) {
      await clients.appClient.v2.updateStreamRules({
        delete: { ids: rules.data.map(rule => rule.id) }, //delete old rules if there happen to be some
      });
    }
    await clients.appClient.v2.updateStreamRules({ //add new rules for stream
        add: [{ value: '@hugbasho hug' }/*, { value: 'follow:'+hugbashoId }*/], //maybe add follower only rule, for rate limit if needed
    });

    const stream = await clients.appClient.v2.searchStream({
    'tweet.fields': ['referenced_tweets', 'author_id'],
    expansions: ['referenced_tweets.id'],
    'user.fields': ['username', 'url'],
    });
    
    stream.autoReconnect = true; //enable auto reconnect for stream
    
    //bot listens for mentions and replies hug emoji to target tweet
    stream.on(ETwitterStreamEvent.Data, async tweet => {

    // Ignore retweets or hugbasho sent tweets
    const isARt = tweet.data.referenced_tweets?.some(tweet => tweet.type === 'retweeted') ?? false;
    if (isARt || tweet.data.author_id === hugbashoId) {
        console.log("we won't reply to our tweets or to retweets :)");
        return;
    }

    //try to reply with hug emoji
    try {
        //check if bot has been mentioned in root tweet or as a reply to a tweet
        if(tweet.data.referenced_tweets == null) {
            await clients.rwClient.v1.reply('🫂', tweet.data.id); //tweet at reply
        }
        else {
            await clients.rwClient.v1.reply('🫂', tweet.data.referenced_tweets[0].id); //tweet at root tweet
        }
    }catch(err){
        //if bot throws error, it is mostlikely because it has already replied to the tweet
        try {
            //reply to tweet
            await clients.rwClient.v1.reply("can't 🫂 more than once per tweet", tweet.data.id); //maybe add an array with a variety of error replies later down the road 
        }catch(err) {
            console.log("couldn't reply, becuase of:\n " + err);
            return;
        }
    }
    });
}
