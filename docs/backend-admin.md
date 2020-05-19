# Admin Interface

Admin Interface for the backend API is arguably the biggest piece of the work. However, it also includes a lot of the functionality which can be mocked in the initial phases of the prototype development.

Backend Admin should consist of:

### Users module [1]:
  - user authentication: login/logout, password reset
  - user invitation via a shared link  
  - list all users, including their status (enabled/disabled)
  - ability to toggle user status (eg: enabled -> disabled)

### Devices module:
  - list all registered devices (searchable by device serial number)
  - show individual device details, such as
    - device description: serial number, reg. date, firmware version
    - device data, where
      - "health status" is displayed as a table with time and status columns
      - all other data is shown as a graph that spans one of the four time periods: _today, this week, this month, this year_.
  - delete all records associated with a module [2]

### Notifications module [3]:
  - alert logged in users if device reports carbon_monoxide >= 9 PPM
  - alert logged in users if device reports health_status as _needs_service, needs_new_filter, gas_leak_
  - list of all notification (filtered by status), which allows us to track notification status
  - show individual notification details, which allows us to:
    - update notification status.
    - track notification history, including date and time of the status changes and the user that initiated them [4].

## Questions and Recommendations:

  1. Users module is a ubiquitous piece of functionality. It can often be implemented via a plugin, and even though it is crucial to this prototype, it's not one of its defining features. As such, I would recommend mocking this functionality in the initial stages of the prototype development.

  This allows us to save development time and reduce project costs by focusing the development on business functionality and implementing this feature at a later stage of the development.

  2. Data which can be used to identify individual and their behaviour might be subject to local as well as international regulations, such as General Data Protection Regulation. If it is, the holder of the data would be legally obliged to delete all data associated with a particular individual upon their request.

  3. Similar to the Users module, the Notifications module is a frequently implemented feature of modern interfaces. However, unlike the Users module, notifications are tightly integrated with the data model employed by the application. As such, I would recommend mocking backend user interface (UI) part of the Notifications module, but fully implementing the support for the notification in the code models and the database structures.

  This approach adds minimal development time in the initial phase of the prototype development, but it would allow us to quickly plugin Notifications UI at a later stage of the development process, with minimal changes to the codebase.

  4. To have a more complete picture of the device's life history, I would recommend keeping track of all changes to the notifications raised by any of the methods.

  This marginally complicates the design of the database but would allow you to keep track of who and when updated notification status, as well as provide you with the time statistic for how long it took to resolve each particular problem.
