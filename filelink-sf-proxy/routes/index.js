let express = require('express');
let router = express.Router();
let multer = require('multer');
let FormData = require('form-data');
let request = require('request');

const config = require('../conf/default');
const queryStr = '';

var upload = multer({ storage: multer.memoryStorage() });

/* GET home page. */
router.post('/', upload.single('cFile'), function(req, res, next) {
  console.log('----> Request File:');
  console.log(req.file);
  console.log('----> Request Body:');
  console.log(req.body);

  if (!req.body.api_key) {
    res.status(404).send('API Key not provided: Unable to create a file attachment');
  } else if (!req.file) {
    res.status(400).send('No file detected. Please attach a file and re-submit.');
  }

  retrieveToken()
    .then((tokenJson) => {
      return verifyAPIToken(req, tokenJson);
    })
    .then((tokenJson) => {
      return retrieveServiceRequestId(req, tokenJson);
    })
    .then((resultsJson) => {
      return postFileToChatter(res, req, resultsJson.token, resultsJson.srid);    
    })
    .then((result) => {
      return createContentDist(result);
    })
    .then((result) => {
      return createExternalFileAndLink(result);
    })
    .then((result) => {
      const returnObj = {
        filename: result.filename,
        public_url: result.public_url
      }
      res.status(200).send(returnObj);
    })
    .catch((err) => {
      console.log('----> Catch triggered from reject. Returned Error: ' + JSON.stringify(err));
      res.status(err.code || 500).send(JSON.stringify(err.message) || JSON.stringify(err));
    });
});

const retrieveToken = () => {
  return new Promise((resolve, reject) => {
    const options = {
      url: (config.org_url + config.oauth_url_ext),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      formData: config.oauth
    };
    console.log('----> Obtaining OAuth Token...');
    request.post(options, (err, resp, body) => {
      const resultJson = JSON.parse(body);
      if (!err) {
        console.log('----> Token Obtained. Verifying that API Key present and valid with server...');
        resolve(resultJson);
      } else {
        console.log('----> Error: ' + err);
        reject({ code: 400, message: 'Unable to save file to server. Please try again later.' });
      }
    });
  });
};

const verifyAPIToken = (req, resultJson) => {
  return new Promise((resolve, reject) => {
    const options = {
      url: (config.org_url + config.query_url_ext) + '?q=' + ("Select Id, Name, ApiKey__c, Private__c, Usage_Limit_Allocation__c, Usage_Limit_Used__c, Usage_Limit_Reset_Date__c FROM Open311ApiKeyConfig__c WHERE ApiKey__c = '" + req.body.api_key.trim() + "'"),
      headers: {
        'Authorization': 'Bearer ' + resultJson.access_token,
      }
    }
    console.log('----> Options[Query]: ' + JSON.stringify(options));
    // Obtain the SR ID using the Case Number
    request.get(options, (err, resp, body) => {
      const queryResultJson = body ? JSON.parse(body) : null;

      if (!err && queryResultJson.totalSize > 0) {
        console.log('----> API Key Verifyed. Proceed to get SR ID for file upload...');

        // TODO: Do verifications of API key limits, etc? Needs verification.

        resolve(resultJson);
      } else {
        console.log('----> Error: ' + err);
        reject({ code: 400, message: 'API Key provided is not valid.' });
      } 
    });
  });
};

const retrieveServiceRequestId = (req, resultJson) => {
  return new Promise((resolve, reject) => {
    const options = {
      url: (config.org_url + config.query_url_ext) + '?q=' + ("Select Id From Case Where CaseNumber = '" + req.body.service_request_id.trim() + "'"),
      headers: {
        'Authorization': 'Bearer ' + resultJson.access_token,
      }
    }
    // Obtain the SR ID using the Case Number
    request.get(options, (err, resp, body) => {
      const queryResultJson = body ? JSON.parse(body) : null;
      const srid = queryResultJson && queryResultJson.totalSize > 0 ? queryResultJson.records[0].Id : null;

      if (!err && srid) {
        console.log('----> Case ID obtained. Proceeded to upload file to Chatter...');
        const combinedResults = {
          token: resultJson.access_token,
          srid: srid
        }
        resolve(combinedResults);
      } else {
        console.log('----> Error: ' + err);
        reject({ code: 400, message: 'Service Request Id was not provided or is not valid.' });
      } 
    });
  });
};

const postFileToChatter = (res, req, token, srId) => {
  return new Promise((resolve, reject) => {
    const file = req.file;
    const json = {
      "body": {"messageSegments":[{"type":"Text","text":""}]},
      "capabilities":{
        "content":{
           "title": file.originalname,
           "description": (req.body.description ? req.body.description : '')
        }
      },
      "feedElementType":"FeedItem",
      "subjectId": srId,
      "visibility": "AllUsers"
    };

    let data = {
      "feedElementFileUpload": {
        "value": file.buffer,
        "options": {
          "filename": file.originalname,
          "contentType": file.mimetype
        }
      },
      "feedElement": JSON.stringify(json)
    };

    const options = {
      url: (config.org_url + config.chatter_url_ext),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json;charset=UTF-8'
      },
      formData: data
    }
    
    request.post(options, (err,resp,body) => {
      if (!err && body) {
        body = JSON.parse(body);
        console.log('----> File to chatter successful. Proceeding in creating ContentDistribution...');
        const resultsJson = {
          "token": token,
          "srid": srId,
          "filename": req.file.originalname,
          "contentVersionId": body.capabilities.content.versionId,
          "mime_type": req.file.mimetype
        };
        resolve(resultsJson);
      } else {
        console.log('----> Error: ' + err);
        reject({code: 400, message: 'Failed to upload file. Please try again later.'});
      }
    });
  });
};

const createContentDist = (resultsJson) => {
  return new Promise((resolve, reject) => {
    const options = {
      url: (config.org_url + config.sobjects_url_ext) + '/ContentDistribution',
      headers: {
        'Authorization': 'Bearer ' + resultsJson.token,
        "Content-Type": "application/json"
      },
      json: {
        "ContentVersionId": resultsJson.contentVersionId, 
        "Name": resultsJson.filename,
        "RelatedRecordId": resultsJson.srid,
        "PreferencesNotifyOnVisit": false
      }
    }
    request.post(options, (err, resp, body) => {
      if (!err && body) {
        const options = {
          url: (config.org_url + config.query_url_ext) + '?q=' + ("Select DistributionPublicUrl From ContentDistribution Where Id = '" + body.id + "'"),
          headers: {
            'Authorization': 'Bearer ' + resultsJson.token,
          }
        }
        // Get the distribution public url.
        request.get(options, (err, resp, body) => {
          if (!err && body) {
            body = JSON.parse(body);
            const dist = body.records[0];

            const endpeice = dist.DistributionPublicUrl.substring(dist.DistributionPublicUrl.indexOf('/a/'),dist.DistributionPublicUrl.length);
            const frontPeice = dist.DistributionPublicUrl.substring(0,dist.DistributionPublicUrl.indexOf('.com')+4);
            resultsJson.public_url = frontPeice + '/sfc/dist/version/download/?oid=' + config.org_id + '&ids=' + resultsJson.contentVersionId + '&d=' + endpeice;
            resolve(resultsJson);    
          } else {
            reject({ code: 400, message: 'Unable to obtain public facing url for distribution.'})
          }
        });
      } else {
        console.log('----> Error: ' + err);
        reject({ code: 400, message: 'Unable to generate public facing url for distribution of file.' });
      } 
    });
  });
};

const createExternalFileAndLink = (resultsJson) => {
  return new Promise((resolve, reject) => {
    const options = {
      url: (config.org_url + config.sobjects_url_ext) + '/Filelink__External_File__c',
      headers: {
        'Authorization': 'Bearer ' + resultsJson.token,
      },
      json: {
        "FileLInk__External_ID__c": resultsJson.contentVersionId,
        "FileLInk__Public_URL__c": resultsJson.public_url,
        "FileLInk__Service__c": "Salesforce",
        "FileLink__Tags__c": "Create",
        "FileLink__Mime_Type__c": resultsJson.mime_type
      }
    }
    request.post(options, (err, resp, body) => {
      const queryResultJson = body;

      if (!err && queryResultJson) {
        console.log('----> FileLink External File created. Proceeding to create custom External Files Related Link record...');
        const options = {
          url: (config.org_url + config.sobjects_url_ext) + '/Filelink__External_File_Relationship__c',
          headers: {
            'Authorization': 'Bearer ' + resultsJson.token,
          },
          json: {
            "FileLInk__Object_ID__c": resultsJson.srid,
            "FileLInk__External_File__c": queryResultJson.id,
          }
        }  

        request.post(options, (err, resp, body) => {
          const queryResultJson = body;
          if (!err && queryResultJson) {
            console.log('----> FileLink External File Relation created. Returning final object result to the user.');
            resolve(resultsJson);    
          } else {
            reject({ code: 400, message: 'An error occured when syncing the external file relations. Please try again later.' });
          }
        });
      } else {
        console.log('----> Error: ' + err);
        reject({ code: 400, message: 'An error occured when syncing the external files. Please try again later.' });
      } 
    });
  });
};

module.exports = router;
