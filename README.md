# FeedFeature
This repositories contains learning material on implementing Feed Feature

### Load Feed From Remote Use Case

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

### Load Feed From Cache Use Case

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

### Validate Feed Cache Use Case

### Primary course (happy path):
1. Execute "Validate Cache" command with above data
2. System fetches feed data from cache.
3. System validates cache is less thab seven days old.

### Retrieval Error course (sad path):
1. System deletes cache.

### Expired cache - error course (sad path):
1. System deletes cache.

### Cache Feed Use Case

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

### Inbox Cache Specs:
✅ Retrieve
    ✅ Empty cache return nil / empty
    ✅ Empty cache twice return nil / empty (no side-effects)
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error returns error (if applicable, e.g., invalid data)
    ✅ Error twice returns same error (if applicable, e.g., invalid data)
- Insert
    ✅ To empty cache stores data
    - To non-empty cache overrides previous data with new data
    - Error (if applicable, e.g., invalid data, no write permission, no empty space)
- Delete
    - Empty cache does nothing (cache stays empty and does not fail)
    - Non-empty cache leaves cache empty
    - Non-empty cache more than once leaves cache empty
    - Error (if applicable, e.g., no delete permission)
- Side-effects must run serially to avoid race-conditions
