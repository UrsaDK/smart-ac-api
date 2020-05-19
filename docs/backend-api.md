# Backend API

The following features should be supported by the backend API:

  - device authentication [1]
  - auto-registration for new devices
  - receipt of sensor data queue, where the queue can consist of multiple records [2].
  - ability to list all users, devices or notifications
  - ability to describe individual users and devices
  - ability to list all data submitted and notifications raised by a single AC device
  - ability to create new notifications for a given data record

In order to support all of these features, the API requires the following endpoints:

`user`
  - POST: Create a new user;
  - GET: List all current users;
  - DELETE(ids): Delete all users identified by the required ids parameter.

`user/:id`
  - GET: Describe a user identified by :id;
  - PUT: Update a user identified by :id;
  - DELETE: Delete a user identified by :id.

`device`
  - GET(sn = nil): List all devices or search for a device with a serial number supplied by the optional "sn" parameter;
  - DELETE(ids): Delete all devices identified by the required ids parameter.

`device/:serial_number`
  - GET: Describe a device identified by :serial_number;
  - PUT: Create or update a device identified by :serial_number;
  - DELETE: Delete a device identified by :serial_number.

`device/:serial_number/data`
  - POST: Run "PUT device/:serial_number" with device data in order to update or create device record, then process submitted data queue for the device, run "POST data/:id/notification" for each queue item, if required;
  - GET: List all data recorded by the device.

`device/:serial_number/notification`
  - GET: Return a list of notifications for the the device identified by :serial_number, where each notification is the latest of a set with matching data ids.

`data/:id/notification`
  - POST: Create a new notification for the data record identified by :id;
  - GET: List all notifications for the given data id.

`notification`
  - GET: Return a list of notifications, where each notification is the latest of a set with matching data ids.

## Questions and Recommendations:

1. The traditional way of authenticating via a username and a password is not very suitable for the internet-of-things (IoT) devices. It raises a lot of security and usability related question: How to ensure that a device connection is not spoofed? How to reset a password securely? How to reset a password on multiple (potentially hundreds) of devices?

To avoid all of these issues, I would recommend using certificate-based authentication model, where each device is supplied with a secure, privately issued, one-way encrypted SSL certificate. Such a certificate cannot be decrypted on the client, and would uniquely identify the client even on their very first connection to the backend.

This approach has three very significant advantages:

  - Easy certificate delivery via an existing firmware upgrade channel: New certificates can be encapsulated in the firmware updates, and can be delivered to the system securely using the current firmware update channel.

  This includes an added benefit of ensuring regular firmware updates for existing devices, as well as provides us with an opportunity to disable tracking of grossly out of date devises via client certificate expiry date.

  - Auto registration of any device with a valid certificate: Since the certificates are issued by the known authority and are validated by the proxy before the connection reaches the back end (see Technical Diagram), we can guarantee that any valid connection from a client that does not exist in our records, is a connection from a new client.

  Thus, it allows us to auto-register new clients on their first connection.

  - DOS protection: moving SSL termination of the secure connection to the http-proxy, which sits in front of the backend (see Technical Diagram), allows us to improve system's resilience.

  This effectively creates a gateway at which all invalid connections are turned away, allowing only valid connections to reach the backend.

2. In the project brief, there is a requirement for the AC client to be able to queue up sensor reading for up to 500 records. I assume that such a requirement is introduced by the hardware limitation of the client. As this requirements are not present on the backend, I propose dropping the 500 item queue limit.

This carries no additional development costs, but it allows us to increase the size of a client's cache by upgrading the client's hardware in the future. What's even better, such an upgrade would require no additional work on the backend.

## Security Considerations

The data collected by the backend is highly technical and by virtue of its source, it can be linking to properties and the individuals that frequent those properties. For example, it can be used to determine both the occupancy pattern and current status of a residence. Thus it is imperative that the data is stored and transmitted in a secure way.

However, this requirement does not apply within a closed ecosystem of the communication between the SSL-terminating proxy, the backend, and the database (see Technical Diagram).

Furthermore, since the prototype will be operating using mock data, we can delay the implementation of a secure SSL-terminating proxy until a later date.

This allows us to focus our initial development on implementing the API and Admin functionality using straightforward http connections.
