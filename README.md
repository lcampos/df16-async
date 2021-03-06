Dreamforce 2016 - Introduction to Batch & Async Apex
===

Sample Force.com application to demo Async Apex.

---
#### Deployment Prerequisites

Make sure to have a sandbox or development org (https://developer.salesforce.com/).

Install Twilio Helper Library for Salesforce https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1a000000AQzf. Make sure you update the TwilioConfig custom setting with your twilio account data.

Will need to create a REST service on https://www.mockable.io to be able to run queueable apex job.

#### Deploy using ANT

1. Clone this repo to get the latest code:
   `git clone https://github.com/lcampos/df16-async.git`

2. Clone the sample credentials file in the build folder, rename it to sfdc-build.properties and update your credentials and org endpoint.

3. Open your terminal or command prompt and navigate to the build folder

4. Run the deploy target by using the following command : `ant deploy`
