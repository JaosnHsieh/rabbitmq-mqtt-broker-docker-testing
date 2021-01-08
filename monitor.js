const mqtt = require('mqtt');

const mqttUrl = `mqtt://localhost:1883`;

const client = mqtt.connect(mqttUrl);
console.log(`$ connecting to ${mqttUrl}`)

let count = 0;
const time = Date.now();

client.on('connect', (connack) => {
  console.log('$ connected');
  setInterval(() => {
    console.log(new Date(), `message received count ${count} average ${Math.floor(count/((Date.now()-time)/1000))}/s`);
  }, 1000);
  client.subscribe(`#`, { qos: 1 }, function (err, granted) {
    if (!err) {
      console.log(`$ subscribed`);
    }
  });
});
client.on('message', (topic, payload) => {
  count++;
});
