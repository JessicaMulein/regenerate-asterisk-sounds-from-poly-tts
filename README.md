# Reprofile your Asterisk Completely using Polly

An additional polly.js has been added to the original project to generate files on demand from FreePBX using the Text to Speech Engine module (https://community.freepbx.org/t/tts-engine-custom-amazon-polly-24-languages/40763).

* Place this whole repo in /opt/aws-nodejs.
* Fill in your options in polly.js.
* Run rebuildsounds.sh
* Verify and move all files from /opt/aws-nodejs/custom-asterisk to /var/lib/asterisk/sounds/en_Salli/ and enable custom sounds.
* Mass mysql import into recordings (https://mangolassi.it/topic/18903/mass-upload-sound-files-into-freepbx/2) using script placed in output dir
* Create Language code record (or let it by uncommenting in SQL) in Admin for en_Salli
* You will need to copy in a few (see the SKIPPED ones from the log output)
* Fully generated Salli set at https://github.com/jessica-mulein/asterisk-custom-poly-sounds (minus SKIPPED)
+ Fully automated Makefile deployment coming soon in alternatives branch
- (Swap out entire sound file setup in seconds with newly tuned voice parameters)

Expects /usr/bin/node

Essentially this lets you change a little configuration about Polly's voice and suddenly your PBX sounds very different.


## Requirements

The only requirement of this application is the Node Package Manager. All other
dependencies (including the AWS SDK for Node.js) can be installed with:

    npm install

## Basic Configuration

You need to set up your AWS security credentials before the sample code is able
to connect to AWS. You can do this by creating a file named "credentials" at ~/.aws/ 
(C:\Users\USER_NAME\.aws\ for Windows users) and saving the following lines in the file:

    [default]
    aws_access_key_id = <your access key id>
    aws_secret_access_key = <your secret key>

See the [Security Credentials](http://aws.amazon.com/security-credentials) page.
It's also possible to configure your credentials via a configuration file or
directly in source. See the AWS SDK for Node.js [Developer Guide](http://docs.aws.amazon.com/AWSJavaScriptSDK/guide/node-configuring.html)
for more information.

## Running the S3 sample

This sample application connects to Amazon's [Simple Storage Service (S3)](http://aws.amazon.com/s3),
creates a bucket, and uploads a file to that bucket. The script will automatically
create the file to upload. All you need to do is run it:

    node sample.js

The S3 documentation has a good overview of the [restrictions for bucket names](http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html)
for when you start making your own buckets.

## License

This sample application is distributed under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

