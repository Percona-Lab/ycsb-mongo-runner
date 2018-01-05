db.createRole({
        "role": "ycsbMongoRunner",
        "privileges": [
                {
                        "resource": {
                                "db": "ycsb_a",
                                "collection": "usertable"
                        },
                        "actions": [
                                "createIndex",
                                "enableSharding",
                                "dropDatabase",
                                "insert",
                                "update",
                                "remove",
                                "find"
                        ]
                },
                {
                        "resource": {
                                "db": "ycsb_b",
                                "collection": "usertable"
                        },
                        "actions": [
                                "createIndex",
                                "enableSharding",
                                "dropDatabase",
                                "insert",
                                "update",
                                "remove",
                                "find"
                        ]
                }
        ],
        "roles": []
});
db.createUser({
        "user": "ycsbMongoRunner",
        "pwd": "123456",
        "roles": [
                "ycsbMongoRunner"
        ]
});
