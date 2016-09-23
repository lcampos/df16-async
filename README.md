Dreamforce 2016 - Introduction to Batch & Async Apex
===

Sample Force.com application to demo Async Apex.

---
#### Deployment Prerequisites

Make sure to have a sandbox or development org (https://developer.salesforce.com/).

#### Deploy using ANT

1. Clone this repo to get the latest code:
   `git clone https://github.com/lcampos/df16-async.git`

2. Clone the sample credentials file in the build folder, rename it to sfdc-build.properties and update your credentials and org endpoint.

3. Open your terminal or command prompt and navigate to the build folder

4. Run the deploy target by using the following command : `ant deploy`
