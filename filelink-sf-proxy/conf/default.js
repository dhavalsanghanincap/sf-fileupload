module.exports = {
  "org_id": process.env.ORG_ID,
  "org_url": process.env.ORG_URL,
  "oauth_url_ext": "/services/oauth2/token",
  "chatter_url_ext": "/services/data/v35.0/chatter/feed-elements",
  "query_url_ext": "/services/data/v41.0/query",
  "sobjects_url_ext": "/services/data/v41.0/sobjects",
  "oauth": {
    "client_id": process.env.CLIENT_ID,
    "client_secret": process.env.CLIENT_SECRET,
    "username": process.env.ORG_USERNAME,
    "password": process.env.ORG_PASSWORD,
    "grant_type": "password"
  }  
}