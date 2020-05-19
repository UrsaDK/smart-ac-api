# AC Client

The following document sums up the requirement and describes the features of the AC client. However, implementation of the AC client is beyond the scope of this prototype.

AC Client should:

  - attempt sending sensor data to the backend API once a minute [1], using a request with a payload that matches the [ac-client JSON schema](./ac-client-schema.json);
  - queue up sensor readings locally if a connection to the backend API could not be established (max. 500 records);
  - release the content of the queue when the connection to the backend AIP is established.

## Questions and Recommendations:

1. Since the project brief discusses tolerable service outage, I will assume that sensor readings are not "time sensitive". Based on this assumption, my recommendation would be to drop multiple re-connect attempts from the AC client altogether.

We are already scheduled to send sensor readings to the backend once a minute. As such, my recommended approach would be to add the data to the queue and attempt sending it in a minute's time, if a current connection to the backend API fails.

This would simplify the code for the client, making AC client easier, quicker, and cheaper to deliver in the future.

It would also reduce the chances of the traffic from multiple clients (possibly, hundreds of them) stacking up and overwhelming the backend API server in the event of a minor service outage, such as a restart of the SSL-terminating-proxy.

2. As part of its spec Smart AC client send back a number of sensor readings. One of them is "health_status". Currently, this is a single value used to describe the status of the AC. A possible improvement to the protocol could be to change "health_status" to carry multiple values.

This would allow us to us to report the status of each individual sensor, such as "temp_sensor_ok; air_sensor_ok; carbon_sensor_error", or notify backend API of multiple events, eg: "needs_service, gas_leak".
