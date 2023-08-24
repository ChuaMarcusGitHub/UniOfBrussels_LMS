@startuml
participant Front_End
entity LoginController
database User_Database
entity Authentication_Service


Front_End -> LoginController: Send Login Credentials

alt Microservice Down
    LoginController -> Front_End: Return "Internal Server error"
end

LoginController --> User_Database: Find user with matching username
LoginController --> LoginController: Verify user credentials

alt User_Database connection failure
    User_Database --> LoginController: return failure to connection
    LoginController -> Front_End: return "error with request, try again later"
end

LoginController --> User_Database: Update last login User_Database
LoginController --> Authentication_Service: send user data; request for authentication (auth) token

alt Authentication_Service Down
    Authentication_Service --> LoginController: return internal server error
    LoginController -> Front_End: retur "error with verifying data, try again later"
end

Authentication_Service  --> LoginController: return auth token
LoginController --> User_Database: Update last login time
LoginController -> Front_End: Send successful login with auth token


@enduml