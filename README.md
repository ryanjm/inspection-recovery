# Inspection Recovery Tool

In the last ditch effort that we need to recover inspections, use this tool. It requires that you email the inspection from the iOS device. have the json + images from the email sent from the iOS device.

## Setup

Put each inspection json and pictures into a seperate folder under `/inspections`.

The script will check for the following:

1. If the inspection object has an id, it will assume that it has already been uploaded.
2. Otherwise it will check to see if any inspection item has an `inspection_id`, if so, it will use that to submit the rest of the inspections.
3. If there is no `inspection_id`, then it will submit the inspection as a new inspection.

## Running

In order to run, you will need the user's access token and subdomain.

```
% ruby recover.rb [SUBDOMAIN] [USER_ACCESS_TOKEN]
```

When you are finished, please make sure to remove uploaded inspections.
