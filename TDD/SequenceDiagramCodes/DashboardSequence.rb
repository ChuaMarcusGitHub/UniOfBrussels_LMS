@startuml
actor User

boundary Dashboard
participant Authentication_Service

entity CourseController
entity CalendarController

database CourseTable
database CalendarDatabase

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

User -> CourseController: Sends authentication token; user details (id)
CourseController --> CourseTable: Request for course list, user id as primary key
CourseTable --> CourseController: Return list of courses where user id matches with listed courses
CourseController -> Dashboard: loads courses returned by controller 

note left: Concurrent with fetching of course data

User -> CalendarController: Sends authentication token; user details (id)
CalendarController --> CalendarDatabase: Request for calendar entries, user id as primary key
CalendarDatabase --> CalendarController: Return list of calendar entries which matches with user id
CalendarController -> Dashboard: loads calendar with relevant entries



@enduml