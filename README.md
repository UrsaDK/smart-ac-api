# Smart AC API

A proof of concept for an API backend designed designed to provide real-time monitoring of network-enabled smart air conditioners.

- [Admin Interface](#admin-interface)
  - [Components](#components)
  - [Questions and Recommendations:](#questions-and-recommendations)
- [The API](#the-api)
  - [Components](#components-1)
  - [Endpoints](#endpoints)
  - [Questions and Recommendations:](#questions-and-recommendations-1)
  - [Security Considerations](#security-considerations)
- [AC Client](#ac-client)
  - [Requirements](#requirements)
  - [Questions and Recommendations](#questions-and-recommendations-2)
- [Related Resources](#related-resources)

## Admin Interface

Admin Interface for the backend API is arguably the biggest piece of the work. However, it also includes a lot of the functionality which can be mocked in the initial phases of the prototype development.

### Components

  - **Users module: [¹](#api-admin-1)**
    - user authentication: login/logout, password reset
    - user invitation via a shared link
    - list all users, including their status (enabled/disabled)
    - ability to toggle user status (eg: enabled -> disabled)

  - **Devices module:**
    - list all registered devices (searchable by device serial number)
    - show individual device details, such as
      - device description: serial number, reg. date, firmware version
      - device data, where
        - "health status" is displayed as a table with time and status columns
        - all other data is shown as a graph that spans one of the four time periods: _today, this week, this month, this year_.
    - delete all records associated with a module [²](#api-admin-2):

  - **Notifications module [³](#api-admin-3):**
    - alert logged in users if device reports carbon_monoxide >= 9 PPM
    - alert logged in users if device reports health_status as _needs_service, needs_new_filter, gas_leak_
    - list of all notification (filtered by status), which allows us to track notification status
    - show individual notification details, which allows us to:
      - update notification status.
      - track notification history, including date and time of the status changes and the user that initiated them [⁴](#api-admin-4).

### Questions and Recommendations:

<ol>
  <li id="api-admin-1">
  Users module is a ubiquitous piece of functionality. It can often be implemented via a plugin, and even though it is crucial to this prototype, it's not one of its defining features. As such, I would recommend mocking this functionality in the initial stages of the prototype development.

  This allows us to save development time and reduce project costs by focusing the development on business functionality and implementing this feature at a later stage of the development.
  </li>

  <li id="api-admin-2">
  Data which can be used to identify individual and their behaviour might be subject to local as well as international regulations, such as General Data Protection Regulation. If it is, the holder of the data would be legally obliged to delete all data associated with a particular individual upon their request.
  </li>

  <li id="api-admin-3">
  Similar to the Users module, the Notifications module is a frequently implemented feature of modern interfaces. However, unlike the Users module, notifications are tightly integrated with the data model employed by the application. As such, I would recommend mocking backend user interface (UI) part of the Notifications module, but fully implementing the support for the notification in the code models and the database structures.

  This approach adds minimal development time in the initial phase of the prototype development, but it would allow us to quickly plugin Notifications UI at a later stage of the development process, with minimal changes to the codebase.
  </li>

  <li id="api-admin-4">
  To have a more complete picture of the device's life history, I would recommend keeping track of all changes to the notifications raised by any of the methods.

  This marginally complicates the design of the database but would allow you to keep track of who and when updated notification status, as well as provide you with the time statistic for how long it took to resolve each particular problem.
  </li>
</ol>

## The API

This would be the main work horse of the application, providing software updates to the ac units and receiving data submitted by the units.

### Components

The following features should be supported by the backend API:

  - device authentication [¹](#api-server-1)
  - auto-registration for new devices
  - receipt of sensor data queue, where the queue can consist of multiple records [²](#api-server-2)
  - ability to list all users, devices or notifications
  - ability to describe individual users and devices
  - ability to list all data submitted and notifications raised by a single AC device
  - ability to create new notifications for a given data record

### Endpoints

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

### Questions and Recommendations:

<ol>
  <li id="api-server-1">
  The traditional way of authenticating via a username and a password is not very suitable for the internet-of-things (IoT) devices. It raises a lot of security and usability related question: How to ensure that a device connection is not spoofed? How to reset a password securely? How to reset a password on multiple (potentially hundreds) of devices?

  To avoid all of these issues, I would recommend using certificate-based authentication model, where each device is supplied with a secure, privately issued, one-way encrypted SSL certificate. Such a certificate cannot be decrypted on the client, and would uniquely identify the client even on their very first connection to the backend.

  This approach has three very significant advantages:

  - Easy certificate delivery via an existing firmware upgrade channel: New certificates can be encapsulated in the firmware updates, and can be delivered to the system securely using the current firmware update channel.
  <br><br>
  This includes an added benefit of ensuring regular firmware updates for existing devices, as well as provides us with an opportunity to disable tracking of grossly out of date devises via client certificate expiry date.

  - Auto registration of any device with a valid certificate: Since the certificates are issued by the known authority and are validated by the proxy before the connection reaches the back end (see Technical Diagram), we can guarantee that any valid connection from a client that does not exist in our records, is a connection from a new client.
  <br><br>
  Thus, it allows us to auto-register new clients on their first connection.

  - DOS protection: moving SSL termination of the secure connection to the http-proxy, which sits in front of the backend (see Technical Diagram), allows us to improve system's resilience.
  <br><br>
  This effectively creates a gateway at which all invalid connections are turned away, allowing only valid connections to reach the backend.

  <li id="api-server-2">
  In the project brief, there is a requirement for the AC client to be able to queue up sensor reading for up to 500 records. I assume that such a requirement is introduced by the hardware limitation of the client. As this requirements are not present on the backend, I propose dropping the 500 item queue limit.

  This carries no additional development costs, but it allows us to increase the size of a client's cache by upgrading the client's hardware in the future. What's even better, such an upgrade would require no additional work on the backend.
  </li>
</ol>

### Security Considerations

The data collected by the backend is highly technical and by virtue of its source, it can be linking to properties and the individuals that frequent those properties. For example, it can be used to determine both the occupancy pattern and current status of a residence. Thus it is imperative that the data is stored and transmitted in a secure way.

However, this requirement does not apply within a closed ecosystem of the communication between the SSL-terminating proxy, the backend, and the database (see Technical Diagram).

Furthermore, since the prototype will be operating using mock data, we can delay the implementation of a secure SSL-terminating proxy until a later date.

This allows us to focus our initial development on implementing the API and Admin functionality using straightforward http connections.

## AC Client

A summary of the features required by the AC client. While reading this, please bear in mind that the actual implementation of the AC client is beyond the scope of this prototype.

### Requirements

AC Client should:

  - attempt sending sensor data to the backend API once a minute [¹](#api-client-1), using a request with a payload that matches the [ac-client JSON schema](./ac-client-schema.json);
  - queue up sensor readings locally if a connection to the backend API could not be established (max. 500 records);
  - release the content of the queue when the connection to the backend AIP is established.

### Questions and Recommendations

<ol>
  <li id="api-client-1">
  Since the project brief discusses tolerable service outage, I will assume that sensor readings are not "time sensitive". Based on this assumption, my recommendation would be to drop multiple re-connect attempts from the AC client altogether.

  We are already scheduled to send sensor readings to the backend once a minute. As such, my recommended approach would be to add the data to the queue and attempt sending it in a minute's time, if a current connection to the backend API fails.

  This would simplify the code for the client, making AC client easier, quicker, and cheaper to deliver in the future.

  It would also reduce the chances of the traffic from multiple clients (possibly, hundreds of them) stacking up and overwhelming the backend API server in the event of a minor service outage, such as a restart of the SSL-terminating-proxy.
  </li>

  <li id="api-client-2">
  As part of its spec Smart AC client send back a number of sensor readings. One of them is "health_status". Currently, this is a single value used to describe the status of the AC. A possible improvement to the protocol could be to change "health_status" to carry multiple values.

  This would allow us to us to report the status of each individual sensor, such as "temp_sensor_ok; air_sensor_ok; carbon_sensor_error", or notify backend API of multiple events, eg: "needs_service, gas_leak".
  </li>
</ol>

## Related Resources

All of the following resources are available in the `docs` folder of this repository:

  - [API's JSON schema](./docs/ac-client-schema.json)
  - [Architecture diagram](./docs/architecture-diagrams.pdf)
  - [Database structure](./docs/database-structure.pdf)
