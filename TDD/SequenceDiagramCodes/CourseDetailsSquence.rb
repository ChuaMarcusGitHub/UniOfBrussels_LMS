@startuml
actor User

boundary Dashboard
participant Authentication_Service

entity CourseController
database CourseTable


note left: User is already successfully logged in with auth token
User -> Authentication_Service: Sends authentication token; user details (id)
Authentication_Service --> User: Return authentication results

alt Authentication token failure (Session Expired)
    Authentication_Service -> User: "Session Expired, Logging out"
    Dashboard --> User: Session logout
else Authentication token failure (Incorrect token)
    Authentication_Service -> User: "Invalid session token, logging out"
    Dashboard --> User: Session logout
end

User -> CourseController: send request for course details, send course Id
CourseTable --> CourseController:  Fetch course data where course id matches
CourseController -> User: Return coure data to user
Dashboard -> Dashboard: Loads data pertaining to courses


@enduml