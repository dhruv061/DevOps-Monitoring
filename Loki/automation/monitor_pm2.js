const pm2 = require('pm2');
const { exec } = require('child_process');

// Path to your Promtail update script
const updatePromtailScript = '/home/ubuntu/pm2-append-promtail.sh';

// Connect to PM2
pm2.connect(function(err) {
  if (err) {
    console.error('Error connecting to PM2:', err);
    process.exit(2);
  }

  console.log('Connected to PM2');

  // Listen for events
  pm2.launchBus(function(err, bus) {
    if (err) {
      console.error('Error launching PM2 bus:', err);
      process.exit(2);
    }

    console.log('PM2 Bus launched, listening for process events...');

    // Listen for 'process:msg' events which include process changes
    bus.on('process:event', function(packet) {
      if (packet.event === 'online') {
        console.log('New process started:', packet.process.name);

        // Run the script to update the Promtail config
        exec(`bash ${updatePromtailScript}`, (error, stdout, stderr) => {
          if (error) {
            console.error(`Error executing script: ${error.message}`);
            return;
          }
          if (stderr) {
            console.error(`Script stderr: ${stderr}`);
            return;
          }
          console.log(`Script output: ${stdout}`);
        });
      }
    });
  });
});
