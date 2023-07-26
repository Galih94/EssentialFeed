# FeedFeature
This repositories contains learning material on implementing Feed Feature

---
# BDD Specs
## Story: Customer requests to see their image feed

## Narative #1
As an online customer
I want the app to automatically load my latest image feed
So i can always enjoy the newest images of my friends

### Scenarios (Acceptance criteria)
Given the customer has connectivity
When the customer requests to see their feed
Then the app should display the latest feed from remote
And replace the cache with new feed

## Narrative #2
As an offline customer 
Iwant the app to show latest saved version of my image feed
So i can always enjoy images of my friends



---
## Load Feed Image Data From Remote Use Case

### Data:
- URL

### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

### Cancel course:
1. System does not deliver image data nor error.

### Invalid data - error course (sad path):
1. System delivers invalid data error.

### No connectivity - error course (sad path):
1. System delivers connectivity error.

---
## Load Feed From Remote Use Case

#### Data:
- URL

### Primary course (happy path):
1. Execute "Load Image Feed" command with above data
2. System downloads data from the url.
3. System validates downloaded data.
4. System create image feed from valid data.
5. System delivers image feed.

### Invalid data - error course (sad path):
1. System delivers invalid error.

### No connectivity - error course (sad path):
1. System delivers connectivity error.

---
## Load Feed Image Data From Cache Use Case

### Data:
- URL

### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.

### Cancel course:
1. System does not delivers image data nor error.

### Retrieveal error course (sad path):
1. System delivers error.

### Empty cache course (sad path):
1. System delivers not found error. 

---
## Load Feed From Cache Use Case

### Primary course (happy path):
1. Execute "Load Image Feed" command with above data
2. System fetches feed data from cache.
3. System validates cache is less thab seven days old.
4. System create image feed from cached data.
5. System delivers image feed.

### Retrieval Error course (sad path):
1. System delivers invalid error.

### Expired cache - error course (sad path):
1. System delivers no image feed.

### Empty Cache - error course (sad path):
1. System delivers no feed items.

---
## Validate Feed Cache Use Case

### Primary course (happy path):
1. Execute "Validate Cache" command with above data
2. System fetches feed data from cache.
3. System validates cache is less thab seven days old.

### Retrieval Error course (sad path):
1. System deletes cache.

### Expired cache - error course (sad path):
1. System deletes cache.

---
## Cache Feed Use Case

#### Data:
- Image Feed

### Primary course (happy path):
1. Execute "Save Image Feed" command with above data
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message. 

### Deleting error course (sad path):
1. System delivers error.

### Saving error course (sad path):
1. System delivers error.

# Inbox Cache Specs:
- [✅] Retrieve
    - [✅] Empty cache return nil / empty
    - [✅] Empty cache twice return nil / empty (no side-effects)
    - [✅] Non-empty cache returns data
    - [✅] Non-empty cache twice returns same data (no side-effects)
    - [✅] Error returns error (if applicable, e.g., invalid data)
    - [✅] Error twice returns same error (if applicable, e.g., invalid data)
- [✅] Insert
    - [✅] To empty cache stores data
    - [✅] To non-empty cache overrides previous data with new data
    - [✅] Error (if applicable, e.g., invalid data, no write permission, no empty space)
- [✅] Delete
    - [✅] Empty cache does nothing (cache stays empty and does not fail)
    - [✅] Non-empty cache leaves cache empty
    - [✅] Error (if applicable, e.g., no delete permission)
- [✅] Side-effects must run serially to avoid race-conditions

# Inbox UX goals for the Feed UI experience:
- [✅] Load feed automatically when view is presented
- [✅] Allow customer to manually reload feed (pull to refresh)
- [✅] Show a loading indicator while loading feed 
- [✅] Render all loaded feed items (location image, description)
- [✅] Image loading experience
    - [✅] Load when image is visible (on screen)
    - [✅] Cancel when image view is out of screen
    - [✅] Show a loading indicator while loading image (shimmer)
    - [✅] Option to retry on image download error
    - [✅] Preload when image view is near visible
- [✅] Create layout for pagination
    -  [✅] Create load more loading indicator
    -  [✅] Create load more error message
- [✅] Infinite Scroll Experience
    -  [✅] Trigger "Load More" action on scroll to bottom
        -  [✅] Only if there are more items to load
        -  [✅] Only if not already loading
    -  [✅] Show loading indicator while loading
    -  [✅] Show error message load more while loading more error
        -  [✅] Tap error message to retry load more
- [✅] Load feed 10 items at a time using Keyset Pagination
    - [✅] First: GET /feed?limit=10
    - [✅] Load More: GET /feed?limit=10&after_id={last_id}
    
## API Specs
### Payload  contract
```
GET /feed

200 RESPONSE

{
    "items": [
        {
            "id": "a UUID",
            "description": "a description",
            "location": "a location",
            "image": "https://a-image.url",
        },
        {
            "id": "another UUID",
            "description": "another description",
            "image": "https://another-image.url"
        },
        {
            "id": "even another UUID",
            "location": "even another location",
            "image": "https://even-another-image.url"
        },
        {
            "id": "yet another UUID",
            "image": "https://yet-another-image.url"
        }
        ...
    ]
}
```
### Feed Image

| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `description` | `String` (optional) |
| `location`    | `String` (optional) |
| `url`         | `URL`               |

---

# Essential Feed App – Image Comments Feature
**Displaying image comments when user taps on an image in the feed.**
*Important: There's no need to cache comments.*
---

## Goals
1. Display a list of comments when the user taps on an image in the feed.
2. Loading the commnets can fail, so you must handle the UI states accordingly.
    - Show a loading spinner while loading the comments.
    - If it fails to load: Show an error message.
    - If it loads successfully: SHow all loaded comments in the order they were returned by the remote API.
3. The loading should start automatically when the user navigates to the screen.
    - The user should also be able to reload the comments manually (Pull-to-refresh).
4. At all times, the user whould have a back button to return to the feed screen.
    - Cancle any running comments API requests when the user navigates back.
5. The comments screen layout should match the UI specs.
    - Present the comment date using relative date formatting, e.g., "1 day ago."
6. The comments screen title should be localized in all languages supported in the project.
7. The Comments screen shpuld support Light and Dark Mode.
8. Write tests to validate your implementation, including unit, integration, and snapshot tests (aim to write the test first!).
---

## API Specs
### Payload  contract
``` 
GET /image/{image-id}/comments
2xx RESPONSE
 
{
    "items": [
        {
            "id": "a UUID",
            "message": "a message",
            "created_at": "2020-5-20T11:24:59+0000",
            "author": { 
                "username": "a username"
            }
        },
        {
            "id": "a UUID",
            "message": "a message",
            "created_at": "2020-5-20T11:24:59+0000",
            "author": { 
                "username": "a username"
            }
        },
        ...
    ]
}
 
```
### Feed Image Comment
| Property      | Type                    |
|---------------|-------------------------|
| `id`          | `UUID`                  |
| `message`     | `String`                |
| `created_at`  | `Date` (ISO8601 STRING) |
| `author`      | `CommentAuthorObject`   |

### Feed Image Comment Author
| Property      | Type                    |
|---------------|-------------------------|
| `username`    | `String`                |
