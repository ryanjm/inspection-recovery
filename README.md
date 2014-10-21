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

## Queries for the server

Manually finalize inspections:

```ruby
Inspection.find([271495, 271496, 271500, 271506]).each { |i| i.finalize!; i.send_notifications }
```

See inspections that haven't been finalized:

```ruby
a = Account.find_by_subdomain("obsidian")
Inspection.between(2.weeks.ago, Time.now).inactive.within_supervisory_structures([a.company]).count
```

Remove duplicate items (assuming there are unique comments to work with)

```ruby
comments = []
a = []
i.reload.inspection_items.each do |item| 
  if comments.index(item.comment) == nil && item.inspection_item_photos.count > 0
    comments << item.comment # First item, cache the comment
  else
    a << item.id
  end
end
a.each { |id| InspectionItem.find(id).destroy }
```


