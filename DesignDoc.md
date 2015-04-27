# fleek design document
fleek is a location-based social iOS app designed to help people discover what they want to do together.
As such it utilizes MapKit and CoreLocation for its GeoLocation capabilities.
It also utilizes Parse as a back-end in order to provide persistence for:

* location favoriting
* anonymous login
* user connections

### Database Design
The database design has three main classes depicted below:

![](https://raw.githubusercontent.com/duliodenis/fleek/master/art/designs/fleek_db_design.png)

### User Class
The **User** class allows a user to provide a nickname that they will be referred to as well as other profile information such as a short bio and a profile image.

### Friend Class

The user can have many friends which are associated with a friendID in the **Friend** class.
If User A and User B are friends then the data would look as follows:

| User        | nickname           | friendID  |
| :-------------: |-------------| -----| ----|
| A      | CaptainKirk | 1 |
| B      | MrSpock | 1 |
| C      | Scotty | null |
| D      | Bones | null |

Note: In the above example User C and D do not belong to a friend group.

There is a **status** column in the class in order to present the two stages of *invite pending* and *friend confirmation*.  Communications checks this status column and can only initiaite communications to a confirmed friend.

### Friend Groups

The **FriendGroup** class is used to keep unique group IDs and to support the naming of a group.


### Support or Contact
Visit [ddApps.co](http://ddapps.co) to see more.
