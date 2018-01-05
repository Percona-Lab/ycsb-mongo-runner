db.getSiblingDB("admin").dropRole("ycsbMongoRunner");
db.getSiblingDB("admin").createRole({
	"role" : "ycsbMongoRunner",
	"privileges" : [
		{
			"resource" : {
				"db" : "ycsb_a",
				"collection" : "usertable"
			},
			"actions" : [
				"enableSharding"
			]
		},
		{
			"resource" : {
				"db" : "ycsb_b",
				"collection" : "usertable"
			},
			"actions" : [
				"enableSharding"
			]
		}
	],
	"roles" : [
		{
			"db" : "ycsb_a",
			"role" : "readWrite"
		},
		{
			"db" : "ycsb_b",
			"role" : "readWrite"
		}
	]
});
db.getSiblingDB("admin").dropUser("ycsbMongoRunner");
db.getSiblingDB("admin").createUser({
        "user" : "ycsbMongoRunner",
        "pwd" : "123456",
        "roles" : [
		{ "db": "admin", "role": "ycsbMongoRunner" }
        ]
});
