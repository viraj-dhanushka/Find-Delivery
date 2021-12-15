# Find-Delivery

Today most service providers (SMEs - Small and Medium Enterprises) use social media to contact customers, publish their shop/service information, collect user feedback etc and in Sri Lanka, currently, there is no community based centralized shopping platform to find the best (nearest, cheapest with the highest quality, fastest etc) shops and services. (based on community ratings, comments etc) Here this app can be used as a centralized platform to manage all these shops/services.

Furthermore, this app acts as a framework and can be easily configured to create any kind of shop specific customer management mobile solution.

## Use Case Diagram
We used use case diagrams to gather requirements of the users of this system. It helped to identify the needs and requirements of this system clearly.

### Actors 
- Primary Actors
- Seller / Shop Owner, Buyer
### Secondary Actors
- Backend System with database

![userCase](https://user-images.githubusercontent.com/59219626/146140670-9597114c-b5c9-40a2-bc2f-c842368a49e3.png)

## Activity Diagram

Activity diagram was also useful to identify the behaviour of the system.  An activity diagram portrays the control flow from a start point to a finish point showing the various decision paths that exist while the activity is being executed.

![activity](https://user-images.githubusercontent.com/59219626/146140755-44e21cce-2193-47e7-ba00-172649e234fb.png)

# Software Design
For designing the software, we used a class diagram and we used a EER diagram for designing the database. 

## Class Diagram

The main identified classes are user, seller, buyer, advertisement, chat, location and notifications. There are two associate classes as well where there are many to many relationships between classes. Classes buyer and seller are inherited from the parent class user. We don’t keep any information about the orders in this system as this is a chat based platform.  
![class-diagram](https://user-images.githubusercontent.com/59219626/146140930-37c18419-a5e7-4078-944b-5dcfd9abe6eb.jpeg)

## EER Diagram

The EER diagram was used for designing the database.

Entities - USER, SELLER, BUYER, LOCATION, COMMENT, NOTIFICATION, CHAT, ADVERTISEMENTS
![EER](https://user-images.githubusercontent.com/59219626/146141082-d0f6142b-af39-44d6-9590-3f9f3f85ec43.png)





