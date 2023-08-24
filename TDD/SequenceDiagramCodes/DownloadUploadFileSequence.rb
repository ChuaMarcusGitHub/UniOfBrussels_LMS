@startuml
actor User

boundary Dashboard
participant Authentication_Service

entity CourseController
database CourseTable
entity FileStorageService

User -> Dashboard: Attaches a file to dashboard, submits the file

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

alt File Uploading by User
    Dashboard -> CourseController: Scan and verify file integrity
    alt File not accepted format or File not safe
        CourseController -> User: Return error "invalid file"
        Dashboard -> Dashboard: Display error message
    end
    CourseController --> FileStorageService: Upload File to storage service
    FileStorageService --> CourseController: Returns Status of upload
        alt FileStorageService returns error
            CourseController --> User: Upload Fail;
            Dashboard -> Dashboard: Visual Feeedback upload failed
            CourseController -> CourseController: Set upload status failure

        else  FileStorageService returns success
            FileStorageService --> CourseController: returns url reference
            CourseController --> CourseTable: Upload file entry into database with url reference, matching with userID and file name
            CourseController -> CourseController: Set upload status success
        end
    CourseController --> User: Returns status of upload
    Dashboard -> Dashboard: Display respective status
        
else File Downloading by User
    User -> CourseController: Send request for file download, param: FileName/id
    CourseController --> CourseTable: fetch entry for file based of FileName/id
    
    alt FileName/Id missing
        CourseController --> User: Return error "error identifying file or download"
        Dashboard -> Dashboard: Display Error

    else FlileName/Id entry not found in database
        CourseController --> User: Return error "File not found in server"
        Dashboard -> Dashboard: Display Error
    end

    CourseTable --> CourseController: Returns data containing download url of file
    CourseController --> FileStorageService: Send request to fetch file
    

    alt FileStorageService Failure Response
        alt FileStorageService down
        FileStorageService --> CourseController: returns internal server error response
       
        else Url is invalid
            FileStorageService --> CourseController: returns invalid url resposne
            CourseController --> CourseController: Set error as invalid url

        else FileStorageService unable to find file
            FileStorageService --> CourseController: returns file not found
            CourseController --> CourseController: Set error as file not found        

        else FileStorageService detects file integrity compromised
            FileStorageService --> CourseController: returns error file
            CourseController --> CourseController: Set error as problem file        
        end
    CourseController --> User: returns error message
    Dashboard -> Dashboard: Display Error

    else FileStorageService Success Response
        FileStorageService --> CourseController: Returns file data
        CourseController --> CourseTable: Updates file entry - times downloaded
        CourseController --> CourseController: Set status as success
        CourseController --> Dashboard: Returns file
        Dashboard -> User: Download file using web browser settings
    end
end

@enduml