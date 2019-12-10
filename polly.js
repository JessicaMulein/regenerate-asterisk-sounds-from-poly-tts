// Load the SDK
var argv = require('optimist').argv;
const AWS = require('aws-sdk')
const Fs = require('fs')
var child_process = require('child_process');
// Create an Polly client
const Polly = new AWS.Polly({
accessKeyId: '-- YOUR ACCESS KEY --',
secretAccessKey: '-- YOUR SECRET KEY --',
signatureVersion: 'v4',
region: 'us-west-2'

})

let params = {
'Text': argv.text,
'Engine': 'neural',
'VoiceId': 'Salli',
'OutputFormat': 'mp3',
'SampleRate': '8000',
'LanguageCode': 'en-US'
}
//'VoiceId': 'Joanna',
//'VoiceId': 'Kendra',

Polly.synthesizeSpeech(params, (err, data) => {
if (err) {
console.log(err.code)
} else if (data) {
if (data.AudioStream instanceof Buffer) {
Fs.writeFile(argv.mp3, data.AudioStream, function(err) {
if (err) {
return console.log(err)
}
console.log('The file was saved!')
var output = child_process.execSync('lame --decode ' + argv.mp3 + ' ' + '-b 8000' + ' ' + argv.wav + '.wav');

        })
    }
}
})
