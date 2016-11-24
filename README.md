```
            _   _                                _
  __ _  ___| |_(_)_   _____  ___ ___  _   _  ___| |__
 / _` |/ __| __| \ \ / / _ \/ __/ _ \| | | |/ __| '_ \
| (_| | (__| |_| |\ V /  __/ (_| (_) | |_| | (__| | | |
 \__,_|\___|\__|_| \_/ \___|\___\___/ \__,_|\___|_| |_|

```

Monitor active couchdb tasks, such as replication, indexing or compaction. Calculates progress and show estimate time of completion.

Usage
=====


    active_couch <couchdb_instances...>

e.g.

    active_couch http://localhost:5984 http://admin:password@example.org

e..g,

	Host: http://admin:***@localhost:5984
	1d3dcd165b46f3f823eb902438083812+continuous+create_target offersets=>offersets_201611242107_2326
	Rate: 735.16 cps
	ETA:  2016-11-25T01:09:43+00:00 (in 3 hours 55 minutes)
	[#.......................................] (2.93%)
	--------------------------------------------------
	http://admin:***@localhost:5984/offersets_201611242107_2326:_design/migrations
	[###.....................................] (9.63%)
	2100.8 cps
	eta: 2016-11-24T21:15:23+00:00 (in 0 hours 0 minutes)
	--------------------------------------------------
	http://admin:***@localhost:5984/offersets_201611242107_2326:_design/views
	[###.....................................] (9.07%)
	1979.6 cps
	eta: 2016-11-24T21:15:27+00:00 (in 0 hours 0 minutes)
	--------------------------------------------------
